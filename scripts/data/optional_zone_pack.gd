extends RefCounted

const COLS: int = 15
const ROWS: int = 23

static var _ZONES: Dictionary = {
	"orin_watchtower":{"name":"Wieża Obserwacyjna Orin","biome":"fort / punkt obserwacyjny","recommended_level":10,"spawn":[7,21],"style":"fort","exits":{"7,22":{"zone_id":"orin_gate","spawn":[7,1]}}},
	"reed_islet":{"name":"Wyspa Stroików","biome":"mokradła / odcięta wyspa","recommended_level":12,"spawn":[7,21],"style":"wetland","exits":{"7,22":{"zone_id":"reed_marsh","spawn":[7,1]}}},
	"ferrum_scrapyard":{"name":"Złomowisko Ferrum","biome":"złom / cewki / warsztat terenowy","recommended_level":17,"spawn":[7,1],"style":"tech","exits":{"7,0":{"zone_id":"ferrum_line","spawn":[7,21]}}},
	"nivra_observatory":{"name":"Obserwatorium Nivra","biome":"grań / stare obserwatorium","recommended_level":23,"spawn":[7,21],"style":"mountain","exits":{"7,22":{"zone_id":"nivra_pass","spawn":[7,1]}}},
	"lumen_vault":{"name":"Krypta Lumen","biome":"ruiny / zamknięte archiwum","recommended_level":28,"spawn":[7,1],"style":"ruins","exits":{"7,0":{"zone_id":"lumen_ruins","spawn":[7,21]}}},
	"aster_grove":{"name":"Ukryty Gaj Aster","biome":"stary las / świetlna polana","recommended_level":32,"spawn":[7,21],"style":"forest","exits":{"7,22":{"zone_id":"aster_woods","spawn":[7,1]}}},
	"echo_sanctum":{"name":"Sanktuarium Echa","biome":"post-game / kryształowe echo","recommended_level":52,"spawn":[1,11],"style":"cave","post_game":true,"exits":{"0,11":{"zone_id":"echo_depths","spawn":[13,11]}}},
	"resonance_annex":{"name":"Aneks Rezonansu","biome":"post-game / eksperymentalne laboratorium","recommended_level":52,"spawn":[1,11],"style":"tech","post_game":true,"exits":{"0,11":{"zone_id":"resonance_lab","spawn":[13,11]}}},
	"outer_trench":{"name":"Rów Zewnętrznej Rafy","biome":"post-game / głęboki prąd","recommended_level":52,"spawn":[1,11],"style":"coast","post_game":true,"exits":{"0,11":{"zone_id":"outer_shelf","spawn":[13,11]}}}
}

static var _SOURCE_EXITS: Dictionary = {
	"orin_gate":{"7,0":{"zone_id":"orin_watchtower","spawn":[7,21]}},
	"reed_marsh":{"7,0":{"zone_id":"reed_islet","spawn":[7,21]}},
	"ferrum_line":{"7,22":{"zone_id":"ferrum_scrapyard","spawn":[7,1]}},
	"nivra_pass":{"7,0":{"zone_id":"nivra_observatory","spawn":[7,21]}},
	"lumen_ruins":{"7,22":{"zone_id":"lumen_vault","spawn":[7,1]}},
	"aster_woods":{"7,0":{"zone_id":"aster_grove","spawn":[7,21]}},
	"echo_depths":{"14,11":{"zone_id":"echo_sanctum","spawn":[1,11]}},
	"resonance_lab":{"14,11":{"zone_id":"resonance_annex","spawn":[1,11]}},
	"outer_shelf":{"14,11":{"zone_id":"outer_trench","spawn":[1,11]}}
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
	if not has_zone(zone_id):
		return {}
	var result: Dictionary = (_ZONES[zone_id] as Dictionary).duplicate(true)
	result["map_rows"] = map_rows(zone_id)
	return result

static func map_rows(zone_id: String) -> Array[String]:
	if not has_zone(zone_id):
		return []
	var data: Dictionary = _ZONES[zone_id] as Dictionary
	return _generate_map(str(data.get("style", "field")), data.get("exits", {}) as Dictionary)

static func exit_at(zone_id: String, tile: Vector2i) -> Dictionary:
	if not has_zone(zone_id):
		return {}
	var exits: Dictionary = (_ZONES[zone_id] as Dictionary).get("exits", {}) as Dictionary
	var key: String = "%d,%d" % [tile.x, tile.y]
	if not exits.has(key):
		return {}
	return (exits[key] as Dictionary).duplicate(true)

static func extra_exit_from(zone_id: String, tile: Vector2i) -> Dictionary:
	if not _SOURCE_EXITS.has(zone_id):
		return {}
	var exits: Dictionary = _SOURCE_EXITS[zone_id] as Dictionary
	var key: String = "%d,%d" % [tile.x, tile.y]
	if not exits.has(key):
		return {}
	return (exits[key] as Dictionary).duplicate(true)

static func patch_rows(zone_id: String, source: Array[String]) -> Array[String]:
	var rows: Array[String] = []
	for row: String in source:
		rows.append(row)
	if not _SOURCE_EXITS.has(zone_id) or rows.size() != ROWS:
		return rows
	for raw_key: Variant in (_SOURCE_EXITS[zone_id] as Dictionary).keys():
		var parts: PackedStringArray = str(raw_key).split(",")
		if parts.size() < 2:
			continue
		var x: int = int(parts[0])
		var y: int = int(parts[1])
		if y >= 0 and y < rows.size():
			rows[y] = _replace_char(rows[y], x, "E")
	return rows

static func source_zone_ids() -> Array[String]:
	var result: Array[String] = []
	for raw_id: Variant in _SOURCE_EXITS.keys():
		result.append(str(raw_id))
	result.sort()
	return result

static func _generate_map(style: String, exits: Dictionary) -> Array[String]:
	var fill: String = "G"
	var border: String = "T"
	match style:
		"wetland", "coast": fill = "A"
		"tech": fill = "D"; border = "K"
		"mountain": fill = "G"; border = "K"
		"ruins": fill = "G"; border = "O"
		"forest": fill = "F"
		"cave": fill = "V"; border = "K"
		"fort": fill = "G"; border = "K"
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
	var obstacle: String = "O"
	if style in ["wetland", "coast"]: obstacle = "W"
	if style in ["tech", "mountain", "fort"]: obstacle = "K"
	if style == "forest": obstacle = "T"
	for pos: Vector2i in [Vector2i(3,4),Vector2i(11,4),Vector2i(4,8),Vector2i(10,8),Vector2i(3,16),Vector2i(11,16),Vector2i(5,19),Vector2i(9,19)]:
		(grid[pos.y] as Array)[pos.x] = obstacle
	for pos: Vector2i in [Vector2i(5,6),Vector2i(9,6),Vector2i(5,14),Vector2i(9,14)]:
		if style not in ["cave", "tech"]:
			(grid[pos.y] as Array)[pos.x] = "F"
	for raw_key: Variant in exits.keys():
		var parts: PackedStringArray = str(raw_key).split(",")
		if parts.size() >= 2:
			var x: int = int(parts[0]); var y: int = int(parts[1])
			if x >= 0 and x < COLS and y >= 0 and y < ROWS:
				(grid[y] as Array)[x] = "E"
	var lines: Array[String] = []
	for raw_row: Variant in grid:
		lines.append("".join(raw_row as Array))
	return lines

static func _replace_char(text: String, index: int, value: String) -> String:
	if index < 0 or index >= text.length():
		return text
	return text.substr(0, index) + value + text.substr(index + 1)
