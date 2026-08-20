extends RefCounted

const CATALOG_PATH: String = "res://data/creatures/families.csv"

static var _loaded: bool = false
static var _families: Array[Dictionary] = []
static var _forms_by_name: Dictionary = {}

static func _ensure_loaded() -> void:
	if _loaded:
		return
	_loaded = true
	_families.clear()
	_forms_by_name.clear()
	var file := FileAccess.open(CATALOG_PATH, FileAccess.READ)
	if file == null:
		push_error("SOMADEX creature catalog missing: %s" % CATALOG_PATH)
		return
	if not file.eof_reached():
		file.get_csv_line()
	while not file.eof_reached():
		var row: PackedStringArray = file.get_csv_line()
		if row.size() < 5 or row[0].strip_edges().is_empty():
			continue
		var family_id: int = int(row[0])
		var family: Dictionary = {
			"family_id": family_id,
			"theme": row[1].strip_edges(),
			"forms": [row[2].strip_edges(), row[3].strip_edges(), row[4].strip_edges()]
		}
		_families.append(family)
		var forms: Array = family["forms"] as Array
		for stage_index: int in range(forms.size()):
			var creature_name: String = str(forms[stage_index])
			if creature_name.is_empty():
				continue
			_forms_by_name[creature_name] = {
				"name": creature_name,
				"family_id": family_id,
				"theme": str(family["theme"]),
				"stage": stage_index + 1,
				"previous": str(forms[stage_index - 1]) if stage_index > 0 else "",
				"next": str(forms[stage_index + 1]) if stage_index + 1 < forms.size() else ""
			}

static func family_count() -> int:
	_ensure_loaded()
	return _families.size()

static func form_count() -> int:
	_ensure_loaded()
	return _forms_by_name.size()

static func all_families() -> Array[Dictionary]:
	_ensure_loaded()
	return _families.duplicate(true)

static func all_base_names() -> Array[String]:
	_ensure_loaded()
	var result: Array[String] = []
	for family: Dictionary in _families:
		var forms: Array = family["forms"] as Array
		if not forms.is_empty():
			result.append(str(forms[0]))
	return result

static func has_form(creature_name: String) -> bool:
	_ensure_loaded()
	return _forms_by_name.has(creature_name)

static func form(creature_name: String) -> Dictionary:
	_ensure_loaded()
	if not _forms_by_name.has(creature_name):
		return {}
	return (_forms_by_name[creature_name] as Dictionary).duplicate(true)

static func family_by_id(family_id: int) -> Dictionary:
	_ensure_loaded()
	for family: Dictionary in _families:
		if int(family["family_id"]) == family_id:
			return family.duplicate(true)
	return {}

static func evolution_of(creature_name: String) -> String:
	return str(form(creature_name).get("next", ""))

static func preevolution_of(creature_name: String) -> String:
	return str(form(creature_name).get("previous", ""))

static func validate() -> Array[String]:
	_ensure_loaded()
	var errors: Array[String] = []
	var ids: Dictionary = {}
	for family: Dictionary in _families:
		var family_id: int = int(family.get("family_id", 0))
		if family_id <= 0:
			errors.append("invalid family id")
		elif ids.has(family_id):
			errors.append("duplicate family id %d" % family_id)
		ids[family_id] = true
		var forms: Array = family.get("forms", []) as Array
		if forms.size() != 3:
			errors.append("family %d does not have 3 forms" % family_id)
		for creature_name_value: Variant in forms:
			var creature_name: String = str(creature_name_value)
			if creature_name.is_empty():
				errors.append("family %d contains empty form" % family_id)
	return errors
