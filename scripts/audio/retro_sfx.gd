extends Node

const MIX_RATE: int = 22050
const MASTER_DB: float = -11.0

const _CUES: Dictionary = {
	"pickup": {"notes":[880.0,1174.0],"ms":55},
	"discovery": {"notes":[523.0,659.0,784.0],"ms":72},
	"station": {"notes":[392.0,523.0,659.0],"ms":85},
	"trainer": {"notes":[220.0,277.0],"ms":82},
	"chapter": {"notes":[330.0,440.0,660.0],"ms":65}
}

var _player: AudioStreamPlayer = null

func play_cue(cue_id: String) -> void:
	var stream: AudioStreamWAV = stream_for(cue_id)
	if stream == null:
		return
	if _player == null:
		_player = AudioStreamPlayer.new()
		_player.volume_db = MASTER_DB
		add_child(_player)
	_player.stream = stream
	_player.play()

static func cue_ids() -> Array[String]:
	var result: Array[String] = []
	for key: Variant in _CUES.keys():
		result.append(str(key))
	result.sort()
	return result

static func stream_for(cue_id: String) -> AudioStreamWAV:
	if not _CUES.has(cue_id):
		return null
	var spec: Dictionary = _CUES[cue_id] as Dictionary
	var notes: Array = spec.get("notes", []) as Array
	var note_ms: int = maxi(30, int(spec.get("ms", 60)))
	if notes.is_empty():
		return null
	var samples_per_note: int = int(float(MIX_RATE) * float(note_ms) / 1000.0)
	var total_samples: int = samples_per_note * notes.size()
	var bytes: PackedByteArray = PackedByteArray()
	bytes.resize(total_samples * 2)
	var sample_index: int = 0
	for raw_note: Variant in notes:
		var frequency: float = maxf(40.0, float(raw_note))
		for i: int in range(samples_per_note):
			var phase: float = fmod(float(i) * frequency / float(MIX_RATE), 1.0)
			var square: float = 1.0 if phase < 0.5 else -1.0
			var envelope: float = 1.0 - float(i) / float(maxi(1, samples_per_note))
			var value: int = clampi(int(square * envelope * 8500.0), -32768, 32767)
			bytes.encode_s16(sample_index * 2, value)
			sample_index += 1
	var stream: AudioStreamWAV = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = MIX_RATE
	stream.stereo = false
	stream.data = bytes
	return stream
