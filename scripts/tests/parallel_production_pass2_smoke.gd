extends SceneTree

const BOSS_AI = preload("res://scripts/data/boss_profile_db.gd")
const TRAINERS = preload("res://scripts/data/runtime_trainer_db.gd")
const FAMILY_TYPES = preload("res://scripts/data/family_type_db.gd")
const TYPE_BALANCE = preload("res://scripts/data/type_balance_db.gd")
const STATUS = preload("res://scripts/data/status_db.gd")
const MOVES = preload("res://scripts/data/move_db.gd")
const RULES = preload("res://scripts/battle/battle_rules.gd")
const MONSTERS = preload("res://scripts/data/monster_db.gd")
const ZONES = preload("res://scripts/data/campaign_zone_db.gd")
const OPTIONAL_ZONES = preload("res://scripts/data/optional_zone_pack.gd")
const OPTIONAL_ENCOUNTERS = preload("res://scripts/data/optional_encounter_db.gd")
const EVENTS = preload("res://scripts/data/campaign_event_db.gd")
const BATCH = preload("res://scripts/battle/production_family_animation_db.gd")
const BATTLE_ART = preload("res://scripts/battle/battle_sprite_art.gd")
const MUSIC = preload("res://scripts/audio/retro_music.gd")
const TRANSITION = preload("res://scripts/ui/scene_transition.gd")

var failures: Array[String] = []

func _init() -> void:
	_validate_bosses()
	_validate_types_moves_statuses()
	_validate_optional_world()
	_validate_animation_batch()
	_validate_audio_and_transition()
	if failures.is_empty():
		print("PARALLEL PRODUCTION PASS 2: PASS · 8 boss AIs · 50 family types · 9 optional zones · 18 events · 60 full animations · 13 music themes")
		quit(0)
	else:
		for failure: String in failures:
			push_error("PASS2: " + failure)
		print("PARALLEL PRODUCTION PASS 2: FAIL (%d)" % failures.size())
		quit(1)

func _validate_bosses() -> void:
	_check(BOSS_AI.BOSS_IDS.size() == 8, "boss AI DB must contain exactly eight main bosses")
	_check(BOSS_AI.validate().is_empty(), "boss AI profiles must validate")
	var mechanics: Dictionary = {}
	for boss_id: String in BOSS_AI.BOSS_IDS:
		_check(TRAINERS.boss_ids().has(boss_id), "AI references non-boss trainer %s" % boss_id)
		var data: Dictionary = BOSS_AI.info(boss_id)
		var mechanic: String = str(data.get("mechanic", ""))
		_check(not mechanic.is_empty(), "%s needs a mechanic" % boss_id)
		_check(not mechanics.has(mechanic), "%s mechanic must be unique" % boss_id)
		mechanics[mechanic] = true
		var phase_names: Array = data.get("phase_names", []) as Array
		var thresholds: Array = data.get("phase_thresholds", []) as Array
		_check(phase_names.size() == thresholds.size() + 1, "%s phase names/thresholds mismatch" % boss_id)
		_check((data.get("cycle", []) as Array).size() >= 4, "%s needs deterministic AI cycle" % boss_id)
		var max_hp: int = 100
		var phase0: int = BOSS_AI.phase_index(boss_id, 100, max_hp)
		var phase_last: int = BOSS_AI.phase_index(boss_id, 1, max_hp)
		_check(phase0 == 0, "%s must start phase 0" % boss_id)
		_check(phase_last >= 1, "%s must enter a later phase at critical HP" % boss_id)
		for turn: int in range(8):
			_check(not BOSS_AI.cycle_pattern(boss_id, turn, 100, 100).is_empty(), "%s AI turn %d has no pattern" % [boss_id, turn])

func _validate_types_moves_statuses() -> void:
	_check(FAMILY_TYPES.validate().is_empty(), "all 50 family types/status mappings must validate")
	_check(TYPE_BALANCE.validate().is_empty(), "type matchup table must validate")
	for family_id: int in range(1, 51):
		var type_id: String = FAMILY_TYPES.type_for_family(family_id)
		_check(type_id in FAMILY_TYPES.CORE_TYPES, "family %d missing core type" % family_id)
		_check(STATUS.ids().has(FAMILY_TYPES.status_for_family(family_id)), "family %d tactical status is unknown" % family_id)
	_check(TYPE_BALANCE.primary_type(MONSTERS.get_monster("Petelka")) == "ELECTRIC", "family 016 must resolve as ELECTRIC from catalog")
	_check(TYPE_BALANCE.primary_type(MONSTERS.get_monster("Wirutek")) == "TORSJA", "family 018 must resolve as TORSJA from catalog")
	_check(TYPE_BALANCE.multiplier("ELECTRIC", ["WAVE"]) > 1.0, "electric must have intended wave advantage")
	_check(TYPE_BALANCE.multiplier("FIRE", ["WAVE"]) < 1.0, "fire must meet wave resistance")
	var strong_status := {"__type":"WAVE"}
	var neutral_status := {"__type":"PHYSICAL"}
	var strong_damage: int = RULES.calculate_damage(8, 8, 7, 20, 0, "ELECTRIC", strong_status, {}, 1.0)
	var neutral_damage: int = RULES.calculate_damage(8, 8, 7, 20, 0, "ELECTRIC", neutral_status, {}, 1.0)
	_check(strong_damage > neutral_damage, "live damage rules must apply type advantage")
	var meta_status := {"__type":"ELECTRIC", "marked":2}
	var ticked: Dictionary = STATUS.tick(meta_status)
	_check(str(ticked.get("__type", "")) == "ELECTRIC", "combat type metadata must survive status ticks")
	_check(int(ticked.get("marked", 0)) == 1, "normal timed statuses must still tick")
	_check(STATUS.interaction_count() >= 25, "status system must retain broad reaction matrix")
	_check(MOVES.count() >= 50, "move library must retain broad move diversity")
	for move_id: String in MOVES.ids():
		var move: Dictionary = MOVES.info(move_id)
		_check(MOVES.validate(move), "move %s violates required contract" % move_id)
		var kind: String = str(move.get("kind", ""))
		var power: int = int(move.get("power", 0))
		var accuracy: float = float(move.get("accuracy", 0.0))
		var cost: int = int(move.get("cost", 0))
		_check(power >= 0 and power <= 14, "move %s power outside production band" % move_id)
		_check(accuracy >= 0.75 and accuracy <= 1.0, "move %s accuracy outside production band" % move_id)
		_check(cost >= 0 and cost <= 3, "move %s cost outside production band" % move_id)
		if kind == "attack":
			_check(power >= 2, "attack %s is too weak to be meaningful" % move_id)
			_check(float(move.get("status_chance", 0.0)) <= 0.75, "attack %s status chance too deterministic" % move_id)
	for status_id: String in STATUS.ids():
		var data: Dictionary = STATUS.info(status_id)
		_check(int(data.get("default_turns", 0)) >= 1 and int(data.get("default_turns", 0)) <= 3, "status %s duration outside production band" % status_id)
		_check(int(data.get("tick_damage", 0)) <= 2, "status %s DOT too high" % status_id)
		var outgoing: float = float(data.get("outgoing_mult", 1.0))
		_check(outgoing >= 0.75 and outgoing <= 1.15, "status %s outgoing multiplier outside balance band" % status_id)

func _validate_optional_world() -> void:
	_check(ZONES.ids().size() == 28, "core campaign ids contract must remain 28")
	_check(OPTIONAL_ZONES.ids().size() == 9, "pass must add exactly nine optional zones")
	_check(ZONES.all_ids().size() == 37, "aggregate world must now expose 37 locations")
	_check(EVENTS.count() == 18, "optional zones need exactly eighteen authored events")
	for zone_id: String in OPTIONAL_ZONES.ids():
		_check(ZONES.has_zone(zone_id), "optional zone %s not reachable through aggregate DB" % zone_id)
		var rows: Array[String] = ZONES.map_rows(zone_id)
		_check(rows.size() == 23, "%s must have 23 rows" % zone_id)
		for row: String in rows:
			_check(row.length() == 15, "%s rows must have 15 columns" % zone_id)
		var pool: Array[Dictionary] = OPTIONAL_ENCOUNTERS.pool(zone_id)
		_check(pool.size() >= 6, "%s needs a dense optional encounter pool" % zone_id)
		_check(OPTIONAL_ENCOUNTERS.rare_species(zone_id).size() == 2, "%s needs exactly two rare encounters" % zone_id)
		var events: Array[Dictionary] = EVENTS.in_zone(zone_id)
		_check(events.size() == 2, "%s needs exactly two optional events" % zone_id)
		var simulated: Dictionary = {}
		if ZONES.is_post_game(zone_id): simulated["defeated_zenith_final"] = true
		if events.size() == 2:
			var first: Dictionary = events[0]
			var second: Dictionary = events[1]
			var first_tile: Vector2i = EVENTS.tile_of(first)
			var second_tile: Vector2i = EVENTS.tile_of(second)
			_check(not EVENTS.at(zone_id, first_tile, simulated).is_empty(), "%s first event must be reachable" % zone_id)
			_check(EVENTS.at(zone_id, second_tile, simulated).is_empty(), "%s second event must wait for first" % zone_id)
			simulated[EVENTS.flag_id(str(first.get("id", "")))] = true
			_check(not EVENTS.at(zone_id, second_tile, simulated).is_empty(), "%s second event must unlock after first" % zone_id)
			for tile: Vector2i in [first_tile, second_tile]:
				var code: String = rows[tile.y].substr(tile.x, 1)
				_check(code in ["P","G","F","D","E","A","V"], "%s event tile must be interactable terrain" % zone_id)
		_validate_return_route(zone_id)

func _validate_return_route(optional_zone: String) -> void:
	var return_targets: Array[String] = []
	for y: int in range(23):
		for x: int in range(15):
			var exit_data: Dictionary = ZONES.exit_at(optional_zone, Vector2i(x,y))
			if not exit_data.is_empty(): return_targets.append(str(exit_data.get("zone_id", "")))
	_check(return_targets.size() == 1, "%s should have one clear return route" % optional_zone)
	if return_targets.is_empty(): return
	var source: String = return_targets[0]
	var found_source_exit: bool = false
	for y: int in range(23):
		for x: int in range(15):
			var source_exit: Dictionary = ZONES.exit_at(source, Vector2i(x,y))
			if str(source_exit.get("zone_id", "")) == optional_zone: found_source_exit = true
	_check(found_source_exit, "%s source %s needs reciprocal optional exit" % [optional_zone, source])

func _validate_animation_batch() -> void:
	_check(BATCH.animation_count() == 27, "new production animation batch must cover 27 forms")
	_check(BATTLE_ART.authored_full_animation_count() >= 60, "full authored animation coverage must rise to at least 60 forms")
	for creature_name: String in BATCH.names():
		_check(BATTLE_ART.has_authored_full_animation(creature_name), "%s not promoted to authored animation runtime" % creature_name)
		for action: String in BATCH.ACTIONS:
			var count: int = BATCH.frame_count(action)
			_check(count == int(BATCH.FRAME_COUNTS[action]), "%s %s frame count mismatch" % [creature_name, action])
			var first: Texture2D = BATCH.frame_texture(creature_name, action, 0)
			var last: Texture2D = BATCH.frame_texture(creature_name, action, count - 1)
			_check(first != null and last != null, "%s %s missing generated package-derived frames" % [creature_name, action])
			if first != null and last != null:
				_check(first.get_image().get_data() != last.get_image().get_data(), "%s %s must visibly animate" % [creature_name, action])

func _validate_audio_and_transition() -> void:
	_check(MUSIC.theme_ids().size() >= 13, "music system needs biome, battle and boss themes")
	var music: Node = MUSIC.new()
	for theme_id: String in MUSIC.theme_ids():
		var stream: AudioStreamWAV = music.make_theme_stream(theme_id)
		_check(stream != null, "theme %s failed generation" % theme_id)
		if stream != null:
			_check(stream.data.size() > 50000, "theme %s PCM stream is unexpectedly short" % theme_id)
			_check(stream.loop_mode == AudioStreamWAV.LOOP_FORWARD, "theme %s must loop" % theme_id)
	music.free()
	_check(MUSIC.theme_for_zone("zenith", "cytadela", false) == "finale", "Zenith must use finale music")
	_check(MUSIC.theme_for_zone("outer_trench", "post-game", true) == "postgame", "deep post-game must use postgame music")
	var transition: Control = TRANSITION.new()
	_check(transition.has_method("play_in"), "scene transition must expose play_in")
	transition.free()

func _check(condition: bool, message: String) -> void:
	if not condition: failures.append(message)
