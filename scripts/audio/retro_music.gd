extends Node

const SAMPLE_RATE: int = 22050
const STEP_SECONDS: float = 0.22
const STEPS: int = 16
const MASTER_GAIN: float = 0.115

const THEMES: Dictionary = {
	"town":{"lead":[60,64,67,64,62,65,69,65,60,64,67,72,69,67,64,62],"bass":[36,36,41,41,38,38,43,43],"tempo":1.00},
	"route":{"lead":[64,67,71,67,66,69,73,69,64,71,74,71,66,69,71,74],"bass":[40,40,42,42,38,38,45,45],"tempo":1.05},
	"cave":{"lead":[48,55,51,58,48,55,60,58,46,53,50,57,46,53,58,55],"bass":[30,30,29,29,27,27,31,31],"tempo":0.90},
	"coast":{"lead":[62,66,69,74,69,66,64,67,71,76,71,67,62,66,71,69],"bass":[38,38,43,43,40,40,45,45],"tempo":0.98},
	"tech":{"lead":[55,62,58,65,55,67,62,70,58,65,60,67,55,62,67,72],"bass":[31,31,34,34,36,36,29,29],"tempo":1.12},
	"ruins":{"lead":[57,60,64,67,64,60,55,59,62,66,62,59,53,57,60,64],"bass":[33,33,36,36,29,29,31,31],"tempo":0.92},
	"forest":{"lead":[65,69,72,69,67,71,74,71,64,67,72,76,72,69,67,64],"bass":[41,41,43,43,38,38,40,40],"tempo":0.96},
	"mountain":{"lead":[50,57,62,57,53,60,65,60,50,59,64,59,53,57,62,67],"bass":[26,26,33,33,29,29,31,31],"tempo":0.88},
	"finale":{"lead":[60,63,67,72,66,69,74,78,60,67,72,75,63,69,74,79],"bass":[36,36,39,39,31,31,34,34],"tempo":1.08},
	"postgame":{"lead":[61,68,73,75,70,73,77,80,61,65,72,77,68,73,75,82],"bass":[37,37,32,32,41,41,36,36],"tempo":0.95},
	"battle":{"lead":[52,59,64,61,55,62,67,64,52,64,69,66,55,62,71,67],"bass":[28,28,31,31,33,33,35,35],"tempo":1.20},
	"trainer_battle":{"lead":[54,61,66,63,57,64,69,66,54,66,71,68,57,64,73,69],"bass":[30,30,33,33,35,35,37,37],"tempo":1.24},
	"boss":{"lead":[48,55,61,58,51,58,64,61,48,60,65,63,51,58,67,64],"bass":[24,24,27,27,29,29,31,31],"tempo":1.28}
}

var player: AudioStreamPlayer = null
var current_theme: String = ""
var _stream_cache: Dictionary = {}

func _ready() -> void:
	player = AudioStreamPlayer.new()
	player.name = "RetroMusicPlayer"
	player.volume_db = -10.0
	add_child(player)

func play_theme(theme_id: String) -> void:
	var safe_id: String = theme_id if THEMES.has(theme_id) else "route"
	if player == null:
		_ready()
	if current_theme == safe_id and player.playing:
		return
	current_theme = safe_id
	var stream: AudioStreamWAV = make_theme_stream(safe_id)
	if stream == null:
		return
	player.stream = stream
	player.play()

func stop_music() -> void:
	if player != null:
		player.stop()
	current_theme = ""

func make_theme_stream(theme_id: String) -> AudioStreamWAV:
	var safe_id: String = theme_id if THEMES.has(theme_id) else "route"
	if _stream_cache.has(safe_id):
		return _stream_cache[safe_id] as AudioStreamWAV
	var data: Dictionary = THEMES[safe_id] as Dictionary
	var lead: Array = data.get("lead", []) as Array
	var bass: Array = data.get("bass", []) as Array
	var tempo: float = maxf(0.70, float(data.get("tempo", 1.0)))
	var step_samples: int = maxi(64, int(round(float(SAMPLE_RATE) * STEP_SECONDS / tempo)))
	var total_samples: int = step_samples * STEPS
	var pcm := PackedByteArray()
	pcm.resize(total_samples * 2)
	for sample_index: int in range(total_samples):
		var step: int = mini(STEPS - 1, int(sample_index / step_samples))
		var local_sample: int = sample_index % step_samples
		var lead_note: int = int(lead[step % lead.size()])
		var bass_note: int = int(bass[int(step / 2) % bass.size()])
		var lead_freq: float = _midi_hz(lead_note)
		var bass_freq: float = _midi_hz(bass_note)
		var time: float = float(sample_index) / float(SAMPLE_RATE)
		var phase: float = float(local_sample) / float(step_samples)
		var envelope: float = minf(1.0, phase * 12.0) * minf(1.0, (1.0 - phase) * 7.0)
		var lead_wave: float = 1.0 if sin(TAU * lead_freq * time) >= 0.0 else -1.0
		var bass_wave: float = (2.0 / PI) * asin(sin(TAU * bass_freq * time))
		var arp_freq: float = lead_freq * (1.5 if step % 4 in [1,3] else 2.0)
		var arp_wave: float = 1.0 if sin(TAU * arp_freq * time) >= 0.0 else -1.0
		var sample: float = (lead_wave * 0.50 + bass_wave * 0.32 + arp_wave * 0.18) * envelope * MASTER_GAIN
		var value: int = clampi(int(round(sample * 32767.0)), -32768, 32767)
		var unsigned: int = value if value >= 0 else 65536 + value
		pcm[sample_index * 2] = unsigned & 0xff
		pcm[sample_index * 2 + 1] = (unsigned >> 8) & 0xff
	var stream := AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = SAMPLE_RATE
	stream.stereo = false
	stream.data = pcm
	stream.loop_mode = AudioStreamWAV.LOOP_FORWARD
	stream.loop_begin = 0
	stream.loop_end = total_samples
	_stream_cache[safe_id] = stream
	return stream

static func theme_for_zone(zone_id: String, biome: String = "", post_game: bool = false) -> String:
	if post_game: return "postgame"
	var text: String = (zone_id + " " + biome).to_lower()
	if "zenith" in text: return "finale"
	if "ferrum" in text or "lab" in text or "coil" in text or "tech" in text: return "tech"
	if "lumen" in text or "ruin" in text or "krypt" in text: return "ruins"
	if "aster" in text or "forest" in text or "las" in text or "gaj" in text: return "forest"
	if "nivra" in text or "mountain" in text or "gór" in text: return "mountain"
	if "koral" in text or "coast" in text or "marea" in text or "rafa" in text or "trench" in text: return "coast"
	if "cave" in text or "echo" in text or "fault" in text or "jask" in text: return "cave"
	if "vela" in text or "orin_gate" == zone_id: return "town"
	return "route"

static func theme_ids() -> Array[String]:
	var result: Array[String] = []
	for raw_id: Variant in THEMES.keys(): result.append(str(raw_id))
	result.sort()
	return result

static func _midi_hz(note: int) -> float:
	return 440.0 * pow(2.0, float(note - 69) / 12.0)
