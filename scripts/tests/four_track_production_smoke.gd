extends SceneTree

const CAPTURE = preload("res://scripts/data/campaign_capture_balance.gd")
const DISCOVERIES = preload("res://scripts/data/campaign_discovery_db.gd")
const ZONES = preload("res://scripts/data/campaign_zone_db.gd")
const NPCS = preload("res://scripts/data/runtime_npc_db.gd")
const PICKUPS = preload("res://scripts/data/pickup_db.gd")
const PROGRESS = preload("res://scripts/data/campaign_progression_db.gd")
const RULES = preload("res://scripts/battle/battle_rules.gd")
const STATUS = preload("res://scripts/data/status_db.gd")
const SFX = preload("res://scripts/audio/retro_sfx.gd")
const WORLD_SCREEN = preload("res://scripts/world/sprite_campaign_world_screen.gd")

var failures: Array[String] = []

func _init() -> void:
	_check_capture_curve()
	_check_discoveries()
	_check_story_ui_contract()
	_check_audio_contract()
	_check_visual_runtime_contract()
	if failures.is_empty():
		print("FOUR TRACK PRODUCTION: PASS · capture rarity · 21 discoveries · animated world · chapter HUD · retro SFX")
		quit(0)
		return
	for failure: String in failures:
		push_error(failure)
	quit(1)

func _check_capture_curve() -> void:
	var common: Dictionary = {"name":"Test","capture_rate":0.30,"rarity":"pospolity"}
	var uncommon: Dictionary = common.duplicate(true)
	uncommon["rarity"] = "niepospolity"
	var rare: Dictionary = common.duplicate(true)
	rare["rarity"] = "rzadki"
	var legendary: Dictionary = common.duplicate(true)
	legendary["rarity"] = "legendarny"
	var common_rate: float = CAPTURE.adjusted_base_rate(common)
	var uncommon_rate: float = CAPTURE.adjusted_base_rate(uncommon)
	var rare_rate: float = CAPTURE.adjusted_base_rate(rare)
	var legendary_rate: float = CAPTURE.adjusted_base_rate(legendary)
	_expect(common_rate > uncommon_rate, "Capture rarity curve: common must be easier than uncommon")
	_expect(uncommon_rate > rare_rate, "Capture rarity curve: uncommon must be easier than rare")
	_expect(rare_rate > legendary_rate, "Capture rarity curve: rare must be easier than legendary")
	_expect(legendary_rate >= CAPTURE.MIN_BASE_RATE, "Capture rarity curve dropped below minimum base rate")
	var plain_status: Dictionary = {}
	var marked_status: Dictionary = {}
	STATUS.apply(marked_status, "marked")
	var plain: float = RULES.capture_chance(rare_rate, 8, 30, 0.0, 0.0, plain_status)
	var marked: float = RULES.capture_chance(rare_rate, 8, 30, 0.0, 0.0, marked_status)
	_expect(marked > plain, "Marked status must still improve rarity-balanced capture chance")

func _check_discoveries() -> void:
	_expect(DISCOVERIES.count() == 21, "Expected exactly 21 Region 1 exploration discoveries")
	var seen_ids: Dictionary = {}
	for discovery_id: String in DISCOVERIES.ids():
		_expect(not seen_ids.has(discovery_id), "Duplicate discovery id: %s" % discovery_id)
		seen_ids[discovery_id] = true
		var data: Dictionary = DISCOVERIES.info(discovery_id)
		var zone_id: String = str(data.get("zone_id", ""))
		var tile: Vector2i = DISCOVERIES.tile_of(data)
		_expect(ZONES.has_zone(zone_id), "Discovery %s uses missing zone %s" % [discovery_id, zone_id])
		_expect(tile.x >= 0 and tile.x < 15 and tile.y >= 0 and tile.y < 23, "Discovery %s is outside map bounds" % discovery_id)
		_expect(ZONES.exit_at(zone_id, tile).is_empty(), "Discovery %s overlaps a zone exit" % discovery_id)
		_expect(NPCS.at(zone_id, tile).is_empty(), "Discovery %s overlaps an NPC" % discovery_id)
		_expect(PICKUPS.at(zone_id, tile).is_empty(), "Discovery %s overlaps a pickup" % discovery_id)
		var rows: Array[String] = ZONES.map_rows(zone_id)
		var has_adjacent_walkable: bool = false
		for direction: Vector2i in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
			var next: Vector2i = tile + direction
			if next.x < 0 or next.x >= 15 or next.y < 0 or next.y >= 23:
				continue
			var code: String = rows[next.y].substr(next.x, 1)
			if code in ["P","G","F","D","E","B","A","V"] and NPCS.at(zone_id, next).is_empty():
				has_adjacent_walkable = true
				break
		_expect(has_adjacent_walkable, "Discovery %s has no reachable adjacent interaction tile" % discovery_id)
		var flags: Dictionary = {}
		_expect(not DISCOVERIES.at(zone_id, tile, flags).is_empty(), "Discovery %s cannot be found before its flag" % discovery_id)
		flags[DISCOVERIES.flag_id(discovery_id)] = true
		_expect(DISCOVERIES.at(zone_id, tile, flags).is_empty(), "Discovery %s repeats after completion flag" % discovery_id)

func _check_story_ui_contract() -> void:
	var flags: Dictionary = {}
	var titles: Dictionary = {}
	for completed: int in range(9):
		if completed > 0:
			var boss_id: String = PROGRESS.BOSS_ORDER[completed - 1]
			flags[PROGRESS.defeated_flag(boss_id)] = true
		var stage: int = mini(PROGRESS.STAGE_VELA_TRIAL + completed, PROGRESS.STAGE_POST_GAME)
		var title: String = PROGRESS.title(stage)
		_expect(not title.is_empty(), "Campaign chapter title missing at completion count %d" % completed)
		titles[title] = true
	_expect(titles.size() == 9, "Campaign HUD should expose 9 distinct chapter states including post-game")

func _check_audio_contract() -> void:
	_expect(SFX.cue_ids().size() >= 5, "Retro SFX needs at least five interaction cues")
	for cue_id: String in SFX.cue_ids():
		var stream: AudioStreamWAV = SFX.stream_for(cue_id)
		_expect(stream != null, "Retro SFX cue failed to build: %s" % cue_id)
		if stream != null:
			_expect(stream.data.size() > 500, "Retro SFX cue is unexpectedly empty: %s" % cue_id)
			_expect(stream.mix_rate == SFX.MIX_RATE, "Retro SFX mix rate mismatch: %s" % cue_id)

func _check_visual_runtime_contract() -> void:
	var screen: Control = WORLD_SCREEN.new()
	_expect(screen.has_method("_draw_environment_motion"), "Sprite world lacks animated environment layer")
	_expect(screen.has_method("_draw_chapter_badge"), "Sprite world lacks chapter HUD badge")
	_expect(screen.has_method("_play_cue"), "Sprite world lacks runtime retro SFX hook")
	screen.free()

func _expect(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
