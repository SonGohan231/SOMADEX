extends RefCounted

const BASE = preload("res://scripts/data/npc_db.gd")
const ELITES = preload("res://scripts/data/postgame_elite_db.gd")

static func in_zone(zone_id: String) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for npc: Dictionary in BASE.in_zone(zone_id):
		var copy: Dictionary = npc.duplicate(true)
		if str(copy.get("id", "")) == "vela_trial":
			copy["tile"] = [7, 4]
		result.append(copy)
	for elite: Dictionary in ELITES.in_zone(zone_id):
		var trainer_id: String = str(elite.get("id", ""))
		result.append({
			"id":trainer_id,
			"name":str(elite.get("name", "Echo")),
			"title":str(elite.get("title", "Rewanż")),
			"zone":zone_id,
			"tile":(elite.get("tile", [7,11]) as Array).duplicate(),
			"trainer":true,
			"post_game":true,
			"color":"8d6de8",
			"dialogue":"Echo poprzedniej próby stabilizuje się. Tym razem przeciwnik zna pełny rytm twojej drużyny."
		})
	return result

static func at(zone_id: String, tile: Vector2i) -> Dictionary:
	for npc: Dictionary in in_zone(zone_id):
		if tile_of(npc) == tile:
			return npc
	return {}

static func tile_of(npc: Dictionary) -> Vector2i:
	var raw_tile: Array = npc.get("tile", []) as Array
	if raw_tile.size() >= 2:
		return Vector2i(int(raw_tile[0]), int(raw_tile[1]))
	return Vector2i(-1, -1)

static func dialogue(npc: Dictionary, flags: Dictionary) -> String:
	var npc_id: String = str(npc.get("id", ""))
	if ELITES.has(npc_id):
		if ELITES.is_defeated(npc_id, flags):
			return "%s: Echo wygasło. Próba została zapisana jako ukończona." % str(npc.get("name", "Echo"))
		if not bool(flags.get("defeated_zenith_final", false)):
			return ELITES.locked_text(npc_id)
		return "%s · %s\n%s" % [str(npc.get("name", "Echo")), str(npc.get("title", "Rewanż")), str(npc.get("dialogue", ""))]
	return BASE.dialogue(npc, flags)

static func count() -> int:
	return BASE.count() + ELITES.count()

static func trainer_ids() -> Array[String]:
	var result: Array[String] = BASE.trainer_ids()
	for trainer_id: String in ELITES.ids():
		if not result.has(trainer_id):
			result.append(trainer_id)
	return result
