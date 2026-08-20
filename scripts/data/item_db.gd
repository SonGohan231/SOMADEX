extends RefCounted

static var _ITEMS: Dictionary = {
	"capture_modules": {
		"name": "Moduł Chwytu",
		"category": "capture",
		"description": "Synchronizuje osłabionego dzikiego Somaskana.",
		"battle_usable": true
	},
	"regenerators": {
		"name": "Regenerator",
		"category": "healing",
		"description": "Przywraca HP aktywnemu partnerowi w walce.",
		"battle_usable": true
	},
	"sondas": {
		"name": "Sonda Vela",
		"category": "analysis",
		"description": "Analizuje pole, rzadkość i podatności przeciwnika.",
		"battle_usable": true
	},
	"resonance_cells": {
		"name": "Ogniwo Rezonansu",
		"category": "trainer",
		"description": "Odnawia 2 punkty Skupienia trenera podczas walki.",
		"battle_usable": true
	}
}

static func ids() -> Array[String]:
	return ["capture_modules", "regenerators", "sondas", "resonance_cells"]

static func info(item_id: String) -> Dictionary:
	if not _ITEMS.has(item_id):
		return {}
	return (_ITEMS[item_id] as Dictionary).duplicate(true)

static func default_inventory() -> Dictionary:
	return {
		"capture_modules": 5,
		"regenerators": 3,
		"sondas": 1,
		"resonance_cells": 1
	}

static func normalize_inventory(raw: Variant) -> Dictionary:
	var normalized: Dictionary = default_inventory()
	if typeof(raw) != TYPE_DICTIONARY:
		return normalized
	var incoming: Dictionary = raw as Dictionary
	for item_id: String in ids():
		normalized[item_id] = maxi(0, int(incoming.get(item_id, normalized[item_id])))
	return normalized

static func count(inventory: Dictionary, item_id: String) -> int:
	return maxi(0, int(inventory.get(item_id, 0)))

static func consume(inventory: Dictionary, item_id: String, amount: int = 1) -> bool:
	var needed: int = maxi(1, amount)
	var current: int = count(inventory, item_id)
	if current < needed:
		return false
	inventory[item_id] = current - needed
	return true
