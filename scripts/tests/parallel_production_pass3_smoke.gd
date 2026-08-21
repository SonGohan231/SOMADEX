extends SceneTree

const ELITES = preload("res://scripts/data/postgame_elite_db.gd")
const TRAINERS = preload("res://scripts/data/runtime_trainer_db.gd")
const NPCS = preload("res://scripts/data/runtime_npc_db.gd")
const BOSS_AI = preload("res://scripts/data/boss_profile_db.gd")
const MONSTERS = preload("res://scripts/data/monster_db.gd")
const ITEMS = preload("res://scripts/data/item_db.gd")
const ZONES = preload("res://scripts/data/campaign_zone_db.gd")
const EVENTS = preload("res://scripts/data/campaign_event_db.gd")
const MOVES = preload("res://scripts/data/move_db.gd")
const BATCH2 = preload("res://scripts/battle/production_family_animation_batch2_db.gd")
const BATTLE_ART = preload("res://scripts/battle/battle_sprite_art.gd")
const MUSIC = preload("res://scripts/audio/retro_music.gd")

const SIGNATURES: Dictionary = {
	"vela_trial":"stability_crush",
	"marea_resonance":"conductive_surge",
	"ferrum_construct":"static_net",
	"nivra_guardian":"deep_freeze",
	"lumen_keeper":"weakness_scan",
	"aster_warden":"emergency_regen",
	"koral_tide":"fracture_wave",
	"zenith_final":"final_harmonic"
}

var failures: Array[String] = []

func _init() -> void:
	_validate_postgame_rematches()
	_validate_boss_signatures()
	_validate_animation_batch()
	_validate_boss_audio()
	if failures.is_empty():
		print("PARALLEL PRODUCTION PASS 3: PASS · 8 rematches · adaptive boss signatures · 78 full animations · 8 individual boss themes")
		quit(0)
		return
	for failure: String in failures:
		push_error("PASS3: " + failure)
	print("PARALLEL PRODUCTION PASS 3: FAIL (%d)" % failures.size())
	quit(1)

func _validate_postgame_rematches() -> void:
	_check(ELITES.count() == 8, "post-game must expose eight boss rematches")
	_check(TRAINERS.rematch_ids().size() == 8, "runtime trainer DB must expose all rematches")
	var locked_flags: Dictionary = {}
	var open_flags: Dictionary = {"defeated_zenith_final":true}
	var occupied: Dictionary = {}
	for trainer_id: String in ELITES.ids():
		_check(TRAINERS.has(trainer_id), "%s missing from runtime trainers" % trainer_id)
		_check(not TRAINERS.can_challenge(trainer_id, locked_flags), "%s must stay locked before Zenith" % trainer_id)
		_check(TRAINERS.can_challenge(trainer_id, open_flags), "%s must unlock after Zenith" % trainer_id)
		var profile_id: String = TRAINERS.boss_profile_id(trainer_id)
		_check(BOSS_AI.has(profile_id), "%s needs a valid inherited boss AI profile" % trainer_id)
		var party: Array = TRAINERS.party(trainer_id)
		_check(party.size() == 6, "%s rematch must use a six-member team" % trainer_id)
		var min_level: int = 999
		for raw_member: Variant in party:
			var member: Dictionary = raw_member as Dictionary
			var name: String = str(member.get("name", ""))
			min_level = mini(min_level, int(member.get("level", 0)))
			_check(MONSTERS.has_monster(name), "%s uses unknown creature %s" % [trainer_id, name])
		_check(min_level >= 52, "%s rematch level must be post-game grade" % trainer_id)
		for raw_item: Variant in TRAINERS.reward_items(trainer_id).keys():
			_check(not ITEMS.info(str(raw_item)).is_empty(), "%s reward uses unknown item %s" % [trainer_id, str(raw_item)])
		var spec: Dictionary = ELITES.info(trainer_id)
		var zone_id: String = str(spec.get("zone", ""))
		_check(ZONES.has_zone(zone_id) and ZONES.is_post_game(zone_id), "%s must live in a post-game zone" % trainer_id)
		var raw_tile: Array = spec.get("tile", []) as Array
		var tile := Vector2i(int(raw_tile[0]), int(raw_tile[1]))
		var key: String = "%s:%d,%d" % [zone_id,tile.x,tile.y]
		_check(not occupied.has(key), "rematch NPC collision at %s" % key)
		occupied[key] = trainer_id
		var npc: Dictionary = NPCS.at(zone_id, tile)
		_check(str(npc.get("id", "")) == trainer_id and bool(npc.get("trainer", false)), "%s must resolve as runtime trainer NPC" % trainer_id)
		var rows: Array[String] = ZONES.map_rows(zone_id)
		var code: String = rows[tile.y].substr(tile.x, 1)
		_check(code in ["P","G","F","D","E","A","V"], "%s NPC must stand on valid terrain" % trainer_id)
		_check(EVENTS.at(zone_id, tile, open_flags).is_empty(), "%s must not overlap an active optional event" % trainer_id)

func _validate_boss_signatures() -> void:
	_check(SIGNATURES.size() == 8, "all eight bosses need unique signature assignments")
	var seen: Dictionary = {}
	for boss_id: String in BOSS_AI.BOSS_IDS:
		var move_id: String = str(SIGNATURES.get(boss_id, ""))
		_check(not move_id.is_empty() and MOVES.has(move_id), "%s signature move missing" % boss_id)
		_check(not seen.has(move_id), "signature move %s is reused" % move_id)
		seen[move_id] = boss_id
		var move: Dictionary = MOVES.info(move_id)
		_check(str(move.get("kind", "")) in ["attack","heal","guard"], "%s signature has invalid kind" % boss_id)
	_check(MOVES.count() >= 54, "expanded tactical library must retain at least 54 moves")

func _validate_animation_batch() -> void:
	_check(BATCH2.animation_count() == 18, "second production animation batch must contain exactly 18 approved forms")
	_check(BATTLE_ART.authored_full_animation_count() >= 78, "full authored animation coverage must reach at least 78 forms")
	for creature_name: String in BATCH2.names():
		_check(BATTLE_ART.has_authored_full_animation(creature_name), "%s was not promoted to authored runtime" % creature_name)
		for action: String in BATCH2.ACTIONS:
			var first: Texture2D = BATCH2.frame_texture(creature_name, action, 0)
			var last: Texture2D = BATCH2.frame_texture(creature_name, action, BATCH2.frame_count(action) - 1)
			_check(first != null and last != null, "%s %s frame generation failed" % [creature_name, action])
			if first != null and last != null and BATCH2.frame_count(action) > 1:
				_check(first.get_image().get_data() != last.get_image().get_data(), "%s %s remains visually static" % [creature_name, action])

func _validate_boss_audio() -> void:
	_check(MUSIC.theme_ids().size() >= 21, "audio library must contain the original 13 plus 8 individual boss themes")
	var theme_seen: Dictionary = {}
	var music: Node = MUSIC.new()
	for boss_id: String in BOSS_AI.BOSS_IDS:
		var theme_id: String = MUSIC.boss_theme(boss_id)
		_check(theme_id != "boss", "%s must have an individual music theme" % boss_id)
		_check(not theme_seen.has(theme_id), "%s shares boss theme %s" % [boss_id, theme_id])
		theme_seen[theme_id] = true
		var stream: AudioStreamWAV = music.make_theme_stream(theme_id)
		_check(stream != null and stream.data.size() > 50000, "%s theme PCM generation failed" % boss_id)
	music.free()

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
