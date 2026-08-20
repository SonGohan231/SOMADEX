extends RefCounted

static var _PICKUPS: Array[Dictionary] = [
	{"id":"vela_module_cache","zone":"vela","tile":[8,14],"item":"capture_modules","amount":2,"label":"Skrzynka modułów","message":"Znalazłeś 2 Moduły Chwytu ukryte przy kanale."},
	{"id":"outskirts_regen_stone","zone":"vela_outskirts","tile":[8,20],"item":"regenerators","amount":1,"label":"Kamień Senny","message":"Pod kamieniem leżał Regenerator."},
	{"id":"outskirts_probe_crate","zone":"vela_outskirts","tile":[6,15],"item":"sondas","amount":1,"label":"Skrzynka badawcza","message":"Znalazłeś Sondę Vela w starej skrzynce."},
	{"id":"route_cell_marker","zone":"resonance_route","tile":[7,12],"item":"resonance_cells","amount":1,"label":"Znacznik pola","message":"Znacznik pola zawierał Ogniwo Rezonansu."},
	{"id":"route_module_grass","zone":"resonance_route","tile":[3,9],"item":"capture_modules","amount":2,"label":"Błysk w trawie","message":"W trawie znalazłeś 2 Moduły Chwytu."},
	{"id":"grove_regen_root","zone":"whispering_grove","tile":[6,17],"item":"regenerators","amount":2,"label":"Korzeń opiekuna","message":"W splątanych korzeniach były 2 Regeneratory."},
	{"id":"coast_probe_shell","zone":"tideglass_coast","tile":[6,21],"item":"sondas","amount":1,"label":"Szklana muszla","message":"W szklanej muszli znalazłeś Sondę Vela."},
	{"id":"coast_cell_bridge","zone":"tideglass_coast","tile":[5,13],"item":"resonance_cells","amount":1,"label":"Skrytka przy pomoście","message":"Skrytka przy pomoście zawierała Ogniwo Rezonansu."},
	{"id":"cave_module_echo","zone":"echo_cave","tile":[6,13],"item":"capture_modules","amount":3,"label":"Echo skrytki","message":"Między kryształami znalazłeś 3 Moduły Chwytu."},
	{"id":"cave_cell_resonator","zone":"echo_cave","tile":[7,9],"item":"resonance_cells","amount":1,"label":"Stary rezonator","message":"Stary rezonator zachował jedno Ogniwo Rezonansu."},
	{"id":"gate_regen_supply","zone":"north_gate","tile":[7,18],"item":"regenerators","amount":2,"label":"Zapas Bramy","message":"Znalazłeś 2 Regeneratory przygotowane dla uczestników próby."},
	{"id":"gate_probe_arena","zone":"north_gate","tile":[7,10],"item":"sondas","amount":1,"label":"Zestaw obserwatora","message":"Zestaw obserwatora zawierał Sondę Vela."}
]

static func ids() -> Array[String]:
	var result: Array[String] = []
	for pickup: Dictionary in _PICKUPS:
		result.append(str(pickup.get("id", "")))
	return result

static func count() -> int:
	return _PICKUPS.size()

static func in_zone(zone_id: String) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for pickup: Dictionary in _PICKUPS:
		if str(pickup.get("zone", "")) == zone_id:
			result.append(pickup.duplicate(true))
	return result

static func at(zone_id: String, tile: Vector2i) -> Dictionary:
	for pickup: Dictionary in _PICKUPS:
		if str(pickup.get("zone", "")) != zone_id:
			continue
		if tile_of(pickup) == tile:
			return pickup.duplicate(true)
	return {}

static func by_id(pickup_id: String) -> Dictionary:
	for pickup: Dictionary in _PICKUPS:
		if str(pickup.get("id", "")) == pickup_id:
			return pickup.duplicate(true)
	return {}

static func tile_of(pickup: Dictionary) -> Vector2i:
	var raw: Variant = pickup.get("tile", [])
	if typeof(raw) == TYPE_ARRAY:
		var arr: Array = raw as Array
		if arr.size() >= 2:
			return Vector2i(int(arr[0]), int(arr[1]))
	return Vector2i(-1, -1)

static func flag_id(pickup_id: String) -> String:
	return "pickup_%s" % pickup_id

static func is_collected(pickup_id: String, flags: Dictionary) -> bool:
	return bool(flags.get(flag_id(pickup_id), false))
