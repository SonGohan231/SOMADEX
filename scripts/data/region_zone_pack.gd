extends RefCounted

const COLS: int = 15
const ROWS: int = 23

static var _ZONES: Dictionary = {
	"orin_gate": {"name":"Brama Orin","biome":"fort / równiny","recommended_level":9,"spawn":[7,21],"style":"town","exits":{"7,22":{"zone_id":"north_gate","spawn":[7,1]},"14,11":{"zone_id":"reed_marsh","spawn":[1,11]}}},
	"reed_marsh": {"name":"Mokradła Stroików","biome":"mokradła / kanały","recommended_level":10,"spawn":[1,11],"style":"wetland","exits":{"0,11":{"zone_id":"orin_gate","spawn":[13,11]},"14,11":{"zone_id":"marea","spawn":[1,11]}}},
	"marea": {"name":"Marea","biome":"port / wybrzeże","recommended_level":12,"spawn":[1,11],"style":"coast_town","exits":{"0,11":{"zone_id":"reed_marsh","spawn":[13,11]},"14,11":{"zone_id":"ferrum_line","spawn":[1,11]}}},
	"ferrum_line": {"name":"Linia Ferrum","biome":"linia przemysłowa / równiny","recommended_level":14,"spawn":[1,11],"style":"tech_route","exits":{"0,11":{"zone_id":"marea","spawn":[13,11]},"14,11":{"zone_id":"ferrum","spawn":[1,11]}}},
	"ferrum": {"name":"Ferrum","biome":"miasto techniczne / warsztaty","recommended_level":16,"spawn":[1,11],"style":"tech_town","exits":{"0,11":{"zone_id":"ferrum_line","spawn":[13,11]},"7,0":{"zone_id":"coil_plant","spawn":[7,21]},"14,11":{"zone_id":"nivra_pass","spawn":[1,11]},"7,22":{"zone_id":"resonance_lab","spawn":[7,1]}}},
	"coil_plant": {"name":"Elektrownia Cewkowa","biome":"elektrownia / wysokie napięcie","recommended_level":18,"spawn":[7,21],"style":"facility","exits":{"7,22":{"zone_id":"ferrum","spawn":[7,1]}}},
	"nivra_pass": {"name":"Przełęcz Nivra","biome":"góry / śnieżny wiatr","recommended_level":20,"spawn":[1,11],"style":"mountain","exits":{"0,11":{"zone_id":"ferrum","spawn":[13,11]},"14,11":{"zone_id":"nivra","spawn":[1,11]}}},
	"nivra": {"name":"Nivra","biome":"górskie miasto / kamienne tarasy","recommended_level":22,"spawn":[1,11],"style":"mountain_town","exits":{"0,11":{"zone_id":"nivra_pass","spawn":[13,11]},"7,0":{"zone_id":"deep_fault","spawn":[7,21]},"14,11":{"zone_id":"lumen_ruins","spawn":[1,11]}}},
	"deep_fault": {"name":"Głęboki Uskok","biome":"jaskinia / głębokie pęknięcie","recommended_level":24,"spawn":[7,21],"style":"cave","exits":{"7,22":{"zone_id":"nivra","spawn":[7,1]}}},
	"lumen_ruins": {"name":"Ruiny Lumen","biome":"ruiny / starożytne pole","recommended_level":25,"spawn":[1,11],"style":"ruins","exits":{"0,11":{"zone_id":"nivra","spawn":[13,11]},"14,11":{"zone_id":"lumen","spawn":[1,11]}}},
	"lumen": {"name":"Lumen","biome":"miasto ruin / archiwum","recommended_level":27,"spawn":[1,11],"style":"ruin_town","exits":{"0,11":{"zone_id":"lumen_ruins","spawn":[13,11]},"14,11":{"zone_id":"aster_woods","spawn":[1,11]}}},
	"aster_woods": {"name":"Las Aster","biome":"stary las / świetlne zarodniki","recommended_level":29,"spawn":[1,11],"style":"forest","exits":{"0,11":{"zone_id":"lumen","spawn":[13,11]},"14,11":{"zone_id":"aster","spawn":[1,11]}}},
	"aster": {"name":"Aster","biome":"leśne miasto / korony drzew","recommended_level":31,"spawn":[1,11],"style":"forest_town","exits":{"0,11":{"zone_id":"aster_woods","spawn":[13,11]},"7,22":{"zone_id":"silent_basin","spawn":[7,1]}}},
	"silent_basin": {"name":"Cicha Niecka","biome":"mistyczna niecka / cisza pola","recommended_level":33,"spawn":[7,1],"style":"mystic","exits":{"7,0":{"zone_id":"aster","spawn":[7,21]},"14,11":{"zone_id":"koral","spawn":[1,11]}}},
	"koral": {"name":"Koral","biome":"miasto raf / zatoka","recommended_level":35,"spawn":[1,11],"style":"coast_town","exits":{"0,11":{"zone_id":"silent_basin","spawn":[13,11]},"14,11":{"zone_id":"koral_shelf","spawn":[1,11]},"7,0":{"zone_id":"zenith_approach","spawn":[7,21]},"7,22":{"zone_id":"outer_shelf","spawn":[7,1]}}},
	"koral_shelf": {"name":"Rafa Koral","biome":"rafa / płycizny","recommended_level":37,"spawn":[1,11],"style":"coast","exits":{"0,11":{"zone_id":"koral","spawn":[13,11]}}},
	"zenith_approach": {"name":"Podejście Zenith","biome":"wysoki szlak / finałowe pole","recommended_level":40,"spawn":[7,21],"style":"finale","exits":{"7,22":{"zone_id":"koral","spawn":[7,1]},"7,0":{"zone_id":"zenith","spawn":[7,21]}}},
	"zenith": {"name":"Zenith","biome":"cytadela / rdzeń rezonansu","recommended_level":44,"spawn":[7,21],"style":"final_town","exits":{"7,22":{"zone_id":"zenith_approach","spawn":[7,1]},"14,11":{"zone_id":"echo_depths","spawn":[1,11]}}},
	"echo_depths": {"name":"Głębie Echa","biome":"post-game / głębokie kryształy","recommended_level":48,"spawn":[1,11],"style":"cave","post_game":true,"exits":{"0,11":{"zone_id":"zenith","spawn":[13,11]}}},
	"resonance_lab": {"name":"Laboratorium Rezonansu","biome":"post-game / badania pola","recommended_level":48,"spawn":[7,1],"style":"facility","post_game":true,"exits":{"7,0":{"zone_id":"ferrum","spawn":[7,21]}}},
	"outer_shelf": {"name":"Zewnętrzna Rafa","biome":"post-game / otwarte morze","recommended_level":48,"spawn":[7,1],"style":"coast","post_game":true,"exits":{"7,0":{"zone_id":"koral","spawn":[7,21]}}}
}

static func ids() -> Array[String]:
	var result: Array[String] = []
	for raw_id: Variant in _ZONES.keys():
		result.append(str(raw_id))
	result.sort()
	return result

static func has_zone(zone_id: String) -> bool:
	return _ZONES.has(zone_id)

static func zone_info(zone_id: String) -> Dictionary:
	if not _ZONES.has(zone_id):
		return {}
	var result: Dictionary = (_ZONES[zone_id] as Dictionary).duplicate(true)
	result["map_rows"] = map_rows(zone_id)
	return result

static func map_rows(zone_id: String) -> Array[String]:
	if not _ZONES.has(zone_id):
		return []
	var data: Dictionary = _ZONES[zone_id] as Dictionary
	return _generate_map(str(data.get("style", "route")), data.get("exits", {}) as Dictionary, str(data.get("name", zone_id)))

static func exit_at(zone_id: String, tile: Vector2i) -> Dictionary:
	if not _ZONES.has(zone_id):
		return {}
	var exits: Dictionary = (_ZONES[zone_id] as Dictionary).get("exits", {}) as Dictionary
	var key: String = "%d,%d" % [tile.x, tile.y]
	if not exits.has(key):
		return {}
	return (exits[key] as Dictionary).duplicate(true)

static func north_gate_exit(tile: Vector2i) -> Dictionary:
	if tile == Vector2i(7, 0):
		return {"zone_id":"orin_gate","spawn":[7,21]}
	return {}

static func patch_base_rows(zone_id: String, source: Array[String]) -> Array[String]:
	var rows: Array[String] = []
	for row: String in source:
		rows.append(row)
	if zone_id == "north_gate" and rows.size() == ROWS:
		rows[0] = _replace_char(rows[0], 7, "E")
	return rows

static func _generate_map(style: String, exits: Dictionary, name: String) -> Array[String]:
	var fill: String = "G"
	var border: String = "T"
	if style == "forest" or style == "forest_town":
		fill = "F"
	if style == "cave":
		fill = "V"
		border = "K"
	if style == "coast" or style == "coast_town" or style == "wetland":
		fill = "A"
	if style == "facility" or style == "tech_route" or style == "tech_town":
		fill = "D"
	if style == "ruins" or style == "ruin_town":
		fill = "G"
	if style == "mystic":
		fill = "V"
	if style == "mountain" or style == "mountain_town" or style == "finale" or style == "final_town":
		fill = "G"
	var grid: Array = []
	for y: int in range(ROWS):
		var row: Array[String] = []
		for x: int in range(COLS):
			row.append(border if x == 0 or x == COLS - 1 or y == 0 or y == ROWS - 1 else fill)
		grid.append(row)
	for y: int in range(1, ROWS - 1):
		(grid[y] as Array)[7] = "P"
	for x: int in range(1, COLS - 1):
		(grid[11] as Array)[x] = "P"
	var town: bool = style.ends_with("town") or style == "town"
	if town:
		_add_town_blocks(grid)
	else:
		_add_biome_features(grid, style)
	for raw_key: Variant in exits.keys():
		var parts: PackedStringArray = str(raw_key).split(",")
		if parts.size() < 2:
			continue
		var x: int = int(parts[0])
		var y: int = int(parts[1])
		if x >= 0 and x < COLS and y >= 0 and y < ROWS:
			(grid[y] as Array)[x] = "E"
	var lines: Array[String] = []
	for raw_row: Variant in grid:
		var chars: Array = raw_row as Array
		lines.append("".join(chars))
	return lines

static func _add_town_blocks(grid: Array) -> void:
	for pos: Vector2i in [Vector2i(3,4),Vector2i(4,4),Vector2i(10,4),Vector2i(11,4),Vector2i(3,16),Vector2i(4,16),Vector2i(10,16),Vector2i(11,16)]:
		(grid[pos.y] as Array)[pos.x] = "H"
	for x: int in range(5, 10):
		(grid[7] as Array)[x] = "P"
		(grid[15] as Array)[x] = "P"
	(grid[10] as Array)[5] = "S"
	(grid[10] as Array)[9] = "C"

static func _add_biome_features(grid: Array, style: String) -> void:
	var obstacle: String = "T"
	if style == "cave" or style == "mystic" or style == "ruins":
		obstacle = "O"
	if style == "facility" or style == "tech_route":
		obstacle = "K"
	if style == "mountain" or style == "finale":
		obstacle = "K"
	if style == "coast" or style == "wetland":
		obstacle = "W"
	for pos: Vector2i in [Vector2i(3,3),Vector2i(11,3),Vector2i(4,7),Vector2i(10,7),Vector2i(3,15),Vector2i(11,15),Vector2i(5,19),Vector2i(9,19)]:
		(grid[pos.y] as Array)[pos.x] = obstacle
	for pos: Vector2i in [Vector2i(5,5),Vector2i(9,5),Vector2i(4,13),Vector2i(10,13),Vector2i(6,18),Vector2i(8,18)]:
		if style not in ["cave", "facility"]:
			(grid[pos.y] as Array)[pos.x] = "F"

static func _replace_char(text: String, index: int, value: String) -> String:
	if index < 0 or index >= text.length():
		return text
	return text.substr(0, index) + value + text.substr(index + 1)
