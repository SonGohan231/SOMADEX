extends SceneTree

const CATALOG = preload("res://scripts/data/creature_catalog.gd")

func _initialize() -> void:
	var errors: Array[String] = CATALOG.validate()
	_expect(CATALOG.family_count() == 50, "expected exactly 50 creature families", errors)
	_expect(CATALOG.form_count() == 150, "expected exactly 150 creature forms", errors)
	_expect(CATALOG.evolution_of("Luzik") == "Warstwin", "Luzik evolution chain is broken", errors)
	_expect(CATALOG.evolution_of("Warstwin") == "Synkronaut", "Warstwin evolution chain is broken", errors)
	_expect(CATALOG.preevolution_of("Rezonar") == "Wibrospiew", "Rezonar preevolution chain is broken", errors)
	_expect(CATALOG.has_form("Wahlik"), "Wahlik missing from catalog", errors)
	_expect(CATALOG.has_form("Mantrik"), "family 50 missing from catalog", errors)
	if errors.is_empty():
		print("CREATURE_CATALOG_SMOKE: PASS")
		quit(0)
		return
	for error_text: String in errors:
		printerr("CREATURE_CATALOG_SMOKE: " + error_text)
	quit(1)

func _expect(condition: bool, message: String, errors: Array[String]) -> void:
	if not condition:
		errors.append(message)
