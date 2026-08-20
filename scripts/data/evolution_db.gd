extends RefCounted

const CATALOG = preload("res://scripts/data/creature_catalog.gd")

const STAGE_2_LEVEL: int = 12
const STAGE_3_LEVEL: int = 28

static func form_info(creature_name: String) -> Dictionary:
	var target: String = creature_name.strip_edges().to_lower()
	if target.is_empty():
		return {}
	for family: Dictionary in CATALOG.all_families():
		var family_id: int = int(family.get("family_id", 0))
		var theme: String = str(family.get("theme", ""))
		var forms: Array = family.get("forms", []) as Array
		for i: int in range(forms.size()):
			var canonical: String = str(forms[i])
			if canonical.to_lower() != target:
				continue
			return {
				"name": _canonical_display_name(canonical),
				"family_id": family_id,
				"theme": theme,
				"stage": i + 1,
				"base": _canonical_display_name(str(forms[0])) if not forms.is_empty() else "",
				"previous": _canonical_display_name(str(forms[i - 1])) if i > 0 else "",
				"next": _canonical_display_name(str(forms[i + 1])) if i + 1 < forms.size() else ""
			}
	return {}

static func canonical_name(creature_name: String) -> String:
	return str(form_info(creature_name).get("name", creature_name))

static func family_id(creature_name: String) -> int:
	return int(form_info(creature_name).get("family_id", 0))

static func stage(creature_name: String) -> int:
	return int(form_info(creature_name).get("stage", 0))

static func base_form(creature_name: String) -> String:
	return str(form_info(creature_name).get("base", ""))

static func next_form(creature_name: String) -> String:
	return str(form_info(creature_name).get("next", ""))

static func previous_form(creature_name: String) -> String:
	return str(form_info(creature_name).get("previous", ""))

static func evolution_level(creature_name: String) -> int:
	match stage(creature_name):
		1:
			return STAGE_2_LEVEL
		2:
			return STAGE_3_LEVEL
		_:
			return -1

static func can_evolve(creature_name: String, level: int) -> bool:
	var threshold: int = evolution_level(creature_name)
	return threshold > 0 and level >= threshold and not next_form(creature_name).is_empty()

static func resolve_name(creature_name: String, level: int) -> String:
	var current: String = canonical_name(creature_name)
	var guard: int = 0
	while can_evolve(current, level) and guard < 3:
		var next_name: String = next_form(current)
		if next_name.is_empty() or next_name == current:
			break
		current = next_name
		guard += 1
	return current

static func chain(creature_name: String) -> Array[String]:
	var info: Dictionary = form_info(creature_name)
	if info.is_empty():
		return []
	var family: Dictionary = CATALOG.family_by_id(int(info.get("family_id", 0)))
	var result: Array[String] = []
	for value: Variant in family.get("forms", []) as Array:
		result.append(_canonical_display_name(str(value)))
	return result

static func _canonical_display_name(value: String) -> String:
	if value.to_lower() == "uczek":
		return "Uczek"
	return value
