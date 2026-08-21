extends SceneTree

const MANIFEST_PATH: String = "res://data/creatures/battle_sprites/seed_manifest.csv"

func _initialize() -> void:
	var errors: Array[String] = []
	var file := FileAccess.open(MANIFEST_PATH, FileAccess.READ)
	_expect(file != null, "seed manifest missing", errors)
	if file == null:
		_finish(errors)
		return
	var header: PackedStringArray = file.get_csv_line()
	_expect(header.size() >= 9, "seed manifest header incomplete", errors)
	var rows: int = 0
	var families: Dictionary = {}
	var names: Dictionary = {}
	var approved: int = 0
	while not file.eof_reached():
		var row: PackedStringArray = file.get_csv_line()
		if row.size() < 9 or row[0].strip_edges().is_empty():
			continue
		rows += 1
		var family_id: int = int(row[0])
		var stage: int = int(row[1])
		var creature_name: String = row[2].strip_edges()
		var status: String = row[5].strip_edges()
		families[family_id] = int(families.get(family_id, 0)) + 1
		_expect(stage in [1, 2, 3], "%s has invalid stage" % creature_name, errors)
		_expect(not names.has(creature_name), "duplicate creature in seed manifest: %s" % creature_name, errors)
		names[creature_name] = true
		_expect(row[7] == "128x128", "%s frame contract mismatch" % creature_name, errors)
		_expect(row[8] == "bottom-center", "%s anchor contract mismatch" % creature_name, errors)
		if status == "approved":
			approved += 1
	_expect(rows == 150, "expected 150 form rows, got %d" % rows, errors)
	_expect(families.size() == 50, "expected 50 families, got %d" % families.size(), errors)
	for family_id: Variant in families.keys():
		_expect(int(families[family_id]) == 3, "family %s does not have three forms" % str(family_id), errors)
	_expect(approved >= 3, "first authored family should be approved", errors)
	_finish(errors)

func _finish(errors: Array[String]) -> void:
	if errors.is_empty():
		print("CREATURE_SEED_MANIFEST_SMOKE: PASS · 50 families · 150 forms · 128x128 bottom-center · staged approval")
		quit(0)
		return
	for error: String in errors:
		printerr("CREATURE_SEED_MANIFEST_SMOKE: " + error)
	quit(1)

func _expect(condition: bool, message: String, errors: Array[String]) -> void:
	if not condition:
		errors.append(message)
