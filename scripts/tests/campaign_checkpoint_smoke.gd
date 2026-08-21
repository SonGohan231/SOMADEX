extends SceneTree

const STATE = preload("res://scripts/core/game_state.gd")
const CHECKPOINT = preload("res://scripts/core/campaign_checkpoint.gd")

var failures: Array[String] = []

func _init() -> void:
	var profile: Dictionary = STATE.new_profile("Luzik")
	var fallback: Dictionary = CHECKPOINT.resolve(profile)
	_check(str(fallback.get("zone_id", "")) == "vela", "new profile must fall back to Vela")
	_check(fallback.get("tile", Vector2i.ZERO) as Vector2i == STATE.START_TILE, "new profile fallback tile must be Vela start")

	var ferrum_tile: Vector2i = Vector2i(8, 10)
	_check(CHECKPOINT.sync(profile, "ferrum", ferrum_tile), "Ferrum checkpoint should sync")
	var ferrum: Dictionary = CHECKPOINT.resolve(profile)
	_check(str(ferrum.get("zone_id", "")) == "ferrum", "checkpoint must remember Ferrum")
	_check(ferrum.get("tile", Vector2i.ZERO) as Vector2i == ferrum_tile, "checkpoint must remember exact player tile")

	var migrated: Dictionary = STATE.migrate(profile)
	var restored: Dictionary = CHECKPOINT.resolve(migrated)
	_check(str(restored.get("zone_id", "")) == "ferrum", "checkpoint must survive save migration")
	_check(restored.get("tile", Vector2i.ZERO) as Vector2i == ferrum_tile, "checkpoint tile must survive save migration")

	_check(CHECKPOINT.sync(migrated, "koral", Vector2i(8, 10)), "newer station should replace older checkpoint")
	var koral: Dictionary = CHECKPOINT.resolve(migrated)
	_check(str(koral.get("zone_id", "")) == "koral", "latest station must become respawn zone")

	var flags: Dictionary = migrated.get("flags", {}) as Dictionary
	flags[CHECKPOINT.FLAG_ZONE] = "missing_zone"
	migrated["flags"] = flags
	var invalid: Dictionary = CHECKPOINT.resolve(migrated)
	_check(str(invalid.get("zone_id", "")) == "vela", "invalid saved checkpoint must safely fall back to Vela")

	if failures.is_empty():
		print("CAMPAIGN CHECKPOINT: PASS · sync · migration · latest station · fallback")
		quit(0)
		return
	for failure: String in failures:
		push_error("CHECKPOINT: " + failure)
	print("CAMPAIGN CHECKPOINT: FAIL (%d)" % failures.size())
	quit(1)

func _check(condition: bool, message: String) -> void:
	if not condition:
		failures.append(message)
