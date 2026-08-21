extends RefCounted

const ITEMS = preload("res://scripts/data/item_db.gd")
const EQUIPMENT = preload("res://scripts/data/equipment_db.gd")
const PACK = preload("res://scripts/data/region_zone_pack.gd")

const MATERIALS: Array[String] = ["alloy_scrap","resonance_dust","glass_fiber","copper_coil","charged_crystal","echo_shard","bio_gel","resin_pod","cryo_salt"]
const UTILITY: Array[String] = ["regenerators","capture_modules","resonance_cells","sondas","phase_barrier","mist_projector","overload_coil","grounding_spike","echo_mine","focus_capacitor","stability_anchor","cryo_pulse","signal_jammer","regen_beacon"]

static var _GEAR_BY_ZONE: Dictionary = {
	"orin_gate":"analysis_visor",
	"marea":"resonance_coat",
	"ferrum":"craft_gloves",
	"coil_plant":"field_generator",
	"nivra":"stability_boots",
	"deep_fault":"echo_hood",
	"lumen":"combo_processor",
	"aster":"medic_harness",
	"silent_basin":"focus_headset",
	"koral":"phase_boots",
	"zenith":"focus_relic",
	"echo_depths":"echo_relic",
	"resonance_lab":"relay_gloves",
	"outer_shelf":"wanderer_boots"
}

# Hidden pickups are intentionally not drawn by campaign_world_screen.gd because
# their IDs begin with secret_ rather than region_. Players discover them by
# checking suspicious path/terrain tiles. The table contains exactly 36 secrets.
static var _SECRET_TILES: Dictionary = {
	"orin_gate":[[5,7],[9,15]],
	"reed_marsh":[[5,7],[9,15]],
	"marea":[[5,7],[9,15]],
	"ferrum_line":[[5,7],[9,15]],
	"ferrum":[[5,7],[9,15]],
	"coil_plant":[[5,7],[9,15]],
	"nivra_pass":[[5,7],[9,15]],
	"nivra":[[5,7],[9,15]],
	"deep_fault":[[5,7],[9,15]],
	"lumen_ruins":[[5,7],[9,15]],
	"lumen":[[5,7],[9,15]],
	"aster_woods":[[5,7],[9,15]],
	"aster":[[5,7],[9,15]],
	"silent_basin":[[5,7],[9,15]],
	"koral":[[5,7],[9,15]],
	"koral_shelf":[[5,7]],
	"zenith_approach":[[5,7]],
	"zenith":[[5,7]],
	"echo_depths":[[5,7]],
	"resonance_lab":[[5,7]],
	"outer_shelf":[[5,7]]
}

static func ids() -> Array[String]:
	var result: Array[String] = []
	for zone_id: String in PACK.ids():
		result.append(_id(zone_id, "a"))
		result.append(_id(zone_id, "b"))
	for secret_id: String in secret_ids():
		result.append(secret_id)
	return result

static func secret_ids() -> Array[String]:
	var result: Array[String] = []
	for zone_id: String in PACK.ids():
		var positions: Array = _SECRET_TILES.get(zone_id, []) as Array
		for index: int in range(positions.size()):
			result.append(_secret_id(zone_id, index))
	return result

static func secret_count() -> int:
	return secret_ids().size()

static func in_zone(zone_id: String) -> Array[Dictionary]:
	if not PACK.has_zone(zone_id):
		return []
	var result: Array[Dictionary] = [_build(zone_id, "a"), _build(zone_id, "b")]
	var positions: Array = _SECRET_TILES.get(zone_id, []) as Array
	for index: int in range(positions.size()):
		result.append(_build_secret(zone_id, index))
	return result

static func at(zone_id: String, tile: Vector2i) -> Dictionary:
	for pickup: Dictionary in in_zone(zone_id):
		if tile_of(pickup) == tile:
			return pickup
	return {}

static func by_id(pickup_id: String) -> Dictionary:
	for zone_id: String in PACK.ids():
		for suffix: String in ["a", "b"]:
			if pickup_id == _id(zone_id, suffix):
				return _build(zone_id, suffix)
		var positions: Array = _SECRET_TILES.get(zone_id, []) as Array
		for index: int in range(positions.size()):
			if pickup_id == _secret_id(zone_id, index):
				return _build_secret(zone_id, index)
	return {}

static func tile_of(pickup: Dictionary) -> Vector2i:
	var raw: Array = pickup.get("tile", []) as Array
	if raw.size() >= 2:
		return Vector2i(int(raw[0]), int(raw[1]))
	return Vector2i(-1, -1)

static func flag_id(pickup_id: String) -> String:
	return "pickup_%s" % pickup_id

static func is_collected(pickup_id: String, flags: Dictionary) -> bool:
	return bool(flags.get(flag_id(pickup_id), false))

static func _id(zone_id: String, suffix: String) -> String:
	return "region_%s_%s" % [zone_id, suffix]

static func _secret_id(zone_id: String, index: int) -> String:
	return "secret_%s_%s" % [zone_id, "a" if index == 0 else "b"]

static func _build(zone_id: String, suffix: String) -> Dictionary:
	var zone_index: int = maxi(0, PACK.ids().find(zone_id))
	var pickup_id: String = _id(zone_id, suffix)
	if suffix == "a":
		var material_id: String = MATERIALS[posmod(zone_index, MATERIALS.size())]
		var material_name: String = str(ITEMS.info(material_id).get("name", material_id))
		return {"id":pickup_id,"zone":zone_id,"tile":[2,11],"item":material_id,"amount":2 + int(zone_index / 8),"message":"Znaleziono materiał: %s." % material_name}
	if _GEAR_BY_ZONE.has(zone_id):
		var gear_id: String = str(_GEAR_BY_ZONE[zone_id])
		var gear_name: String = str(EQUIPMENT.info(gear_id).get("name", gear_id))
		return {"id":pickup_id,"zone":zone_id,"tile":[13,11],"gear":gear_id,"amount":1,"message":"Znaleziono wyposażenie: %s." % gear_name}
	var utility_id: String = UTILITY[posmod(zone_index * 3 + 2, UTILITY.size())]
	var utility_name: String = str(ITEMS.info(utility_id).get("name", utility_id))
	return {"id":pickup_id,"zone":zone_id,"tile":[13,11],"item":utility_id,"amount":1 + int(zone_index / 12),"message":"Znaleziono: %s." % utility_name}

static func _build_secret(zone_id: String, index: int) -> Dictionary:
	var positions: Array = _SECRET_TILES.get(zone_id, []) as Array
	if index < 0 or index >= positions.size():
		return {}
	var raw_tile: Array = positions[index] as Array
	var zone_index: int = maxi(0, PACK.ids().find(zone_id))
	var pickup_id: String = _secret_id(zone_id, index)
	if index == 0:
		var item_id: String = MATERIALS[posmod(zone_index * 2 + 3, MATERIALS.size())]
		var item_name: String = str(ITEMS.info(item_id).get("name", item_id))
		return {"id":pickup_id,"zone":zone_id,"tile":raw_tile.duplicate(),"item":item_id,"amount":3 + int(zone_index / 10),"secret":true,"message":"SEKRET: znaleziono %s." % item_name}
	var utility_id: String = UTILITY[posmod(zone_index * 5 + 1, UTILITY.size())]
	var utility_name: String = str(ITEMS.info(utility_id).get("name", utility_id))
	return {"id":pickup_id,"zone":zone_id,"tile":raw_tile.duplicate(),"item":utility_id,"amount":1,"secret":true,"message":"SEKRET: ukryta skrytka zawiera %s." % utility_name}
