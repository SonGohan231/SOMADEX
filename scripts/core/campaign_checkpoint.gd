extends RefCounted

const STATE = preload("res://scripts/core/game_state.gd")
const ZONES = preload("res://scripts/data/campaign_zone_db.gd")

const FLAG_ZONE: String = "checkpoint_zone"
const FLAG_X: String = "checkpoint_x"
const FLAG_Y: String = "checkpoint_y"

static func sync(profile: Dictionary, zone_id: String, player_tile: Vector2i) -> bool:
	if not ZONES.has_zone(zone_id) or not _inside_zone(zone_id, player_tile):
		return false
	var flags: Dictionary = profile.get("flags", {}) as Dictionary
	flags[FLAG_ZONE] = zone_id
	flags[FLAG_X] = player_tile.x
	flags[FLAG_Y] = player_tile.y
	profile["flags"] = flags
	return true

static func resolve(profile: Dictionary) -> Dictionary:
	var flags: Dictionary = profile.get("flags", {}) as Dictionary
	var zone_id: String = str(flags.get(FLAG_ZONE, "vela"))
	var tile: Vector2i = Vector2i(
		int(flags.get(FLAG_X, STATE.START_TILE.x)),
		int(flags.get(FLAG_Y, STATE.START_TILE.y))
	)
	if not ZONES.has_zone(zone_id) or not _inside_zone(zone_id, tile):
		return {"zone_id":"vela", "tile":STATE.START_TILE}
	return {"zone_id":zone_id, "tile":tile}

static func has_checkpoint(profile: Dictionary) -> bool:
	var flags: Dictionary = profile.get("flags", {}) as Dictionary
	return flags.has(FLAG_ZONE) and ZONES.has_zone(str(flags.get(FLAG_ZONE, "")))

static func _inside_zone(zone_id: String, tile: Vector2i) -> bool:
	var rows: Array[String] = ZONES.map_rows(zone_id)
	if tile.y < 0 or tile.y >= rows.size():
		return false
	var row: String = rows[tile.y]
	return tile.x >= 0 and tile.x < row.length()
