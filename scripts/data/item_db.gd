extends RefCounted

const CORE_IDS: Array[String] = ["capture_modules", "regenerators", "sondas", "resonance_cells"]
const MATERIAL_IDS: Array[String] = ["alloy_scrap", "resonance_dust", "glass_fiber", "copper_coil", "charged_crystal", "echo_shard", "bio_gel", "resin_pod", "cryo_salt"]
const GADGET_IDS: Array[String] = ["phase_barrier", "mist_projector", "overload_coil", "grounding_spike", "echo_mine", "emergency_shunt", "focus_capacitor", "stability_anchor", "resin_capsule", "cryo_pulse", "signal_jammer", "regen_beacon"]

static var _ITEMS: Dictionary = {
	"capture_modules": {"name":"Moduł Chwytu","category":"capture","description":"Synchronizuje osłabionego dzikiego Somaskana.","battle_usable":true},
	"regenerators": {"name":"Regenerator","category":"healing","description":"Przywraca HP aktywnemu partnerowi w walce.","battle_usable":true},
	"sondas": {"name":"Sonda Vela","category":"analysis","description":"Analizuje pole, rzadkość i podatności przeciwnika.","battle_usable":true},
	"resonance_cells": {"name":"Ogniwo Rezonansu","category":"trainer","description":"Odnawia 2 punkty Skupienia trenera podczas walki.","battle_usable":true},
	"alloy_scrap": {"name":"Odłamek Stopu","category":"material","description":"Lekki stop odzyskiwany z urządzeń i ruin.","battle_usable":false},
	"resonance_dust": {"name":"Pył Rezonansowy","category":"material","description":"Drobny materiał reagujący na pole Somaskanów.","battle_usable":false},
	"glass_fiber": {"name":"Włókno Szkliste","category":"material","description":"Elastyczne włókno do obudów i projektorów.","battle_usable":false},
	"copper_coil": {"name":"Cewka Miedziana","category":"material","description":"Element przewodzący stosowany w gadżetach.","battle_usable":false},
	"charged_crystal": {"name":"Kryształ Ładunku","category":"material","description":"Magazynuje krótkie impulsy pola.","battle_usable":false},
	"echo_shard": {"name":"Odłamek Echa","category":"material","description":"Fragment minerału pamiętający drgania otoczenia.","battle_usable":false},
	"bio_gel": {"name":"Biogel","category":"material","description":"Materiał regeneracyjny do urządzeń wsparcia.","battle_usable":false},
	"resin_pod": {"name":"Zasobnik Żywicy","category":"material","description":"Lepka substancja do kapsuł pola.","battle_usable":false},
	"cryo_salt": {"name":"Sól Kriogeniczna","category":"material","description":"Stabilny materiał do krótkiego wychładzania pola.","battle_usable":false},
	"phase_barrier": {"name":"Bariera Fazowa","category":"gadget","description":"Jednorundowa osłona partnera.","battle_usable":true},
	"mist_projector": {"name":"Projektor Mgły","category":"gadget","description":"Nakłada MOKRY i otwiera kombinacje.","battle_usable":true},
	"overload_coil": {"name":"Cewka Przeciążenia","category":"gadget","description":"Bojowy impuls elektryczny.","battle_usable":true},
	"grounding_spike": {"name":"Kotwa Uziemiająca","category":"gadget","description":"Kotwiczy przeciwnika w polu.","battle_usable":true},
	"echo_mine": {"name":"Mina Echa","category":"gadget","description":"Fala zwrotna destabilizująca cel.","battle_usable":true},
	"emergency_shunt": {"name":"Bocznik Awaryjny","category":"gadget","description":"Natychmiastowe wsparcie HP.","battle_usable":true},
	"focus_capacitor": {"name":"Kondensator Focus","category":"gadget","description":"Odzyskuje Focus trenera.","battle_usable":true},
	"stability_anchor": {"name":"Kotwa Stabilności","category":"gadget","description":"Odbudowuje koncentrację trenera.","battle_usable":true},
	"resin_capsule": {"name":"Kapsuła Żywicy","category":"gadget","description":"Nakłada ŻYWICĘ na cel.","battle_usable":true},
	"cryo_pulse": {"name":"Impuls Kriogeniczny","category":"gadget","description":"Wychładza przeciwnika.","battle_usable":true},
	"signal_jammer": {"name":"Zakłócacz Sygnału","category":"gadget","description":"Zakłóca następną odpowiedź celu.","battle_usable":true},
	"regen_beacon": {"name":"Znacznik Regeneracji","category":"gadget","description":"Nadaje partnerowi REGENERACJĘ.","battle_usable":true}
}

static func ids() -> Array[String]:
	var result: Array[String] = []
	for item_id: String in CORE_IDS:
		result.append(item_id)
	return result

static func all_ids() -> Array[String]:
	var result: Array[String] = []
	for item_id: String in CORE_IDS:
		result.append(item_id)
	for item_id: String in MATERIAL_IDS:
		result.append(item_id)
	for item_id: String in GADGET_IDS:
		result.append(item_id)
	return result

static func material_ids() -> Array[String]:
	var result: Array[String] = []
	for item_id: String in MATERIAL_IDS:
		result.append(item_id)
	return result

static func gadget_ids() -> Array[String]:
	var result: Array[String] = []
	for item_id: String in GADGET_IDS:
		result.append(item_id)
	return result

static func info(item_id: String) -> Dictionary:
	if not _ITEMS.has(item_id):
		return {}
	return (_ITEMS[item_id] as Dictionary).duplicate(true)

static func default_inventory() -> Dictionary:
	var inventory: Dictionary = {}
	for item_id: String in all_ids():
		inventory[item_id] = 0
	inventory["capture_modules"] = 5
	inventory["regenerators"] = 3
	inventory["sondas"] = 1
	inventory["resonance_cells"] = 1
	inventory["alloy_scrap"] = 4
	inventory["resonance_dust"] = 4
	inventory["glass_fiber"] = 2
	inventory["copper_coil"] = 2
	inventory["bio_gel"] = 2
	inventory["resin_pod"] = 2
	inventory["phase_barrier"] = 1
	inventory["mist_projector"] = 1
	return inventory

static func normalize_inventory(raw: Variant) -> Dictionary:
	var normalized: Dictionary = default_inventory()
	if typeof(raw) != TYPE_DICTIONARY:
		return normalized
	var incoming: Dictionary = raw as Dictionary
	for item_id: String in all_ids():
		normalized[item_id] = maxi(0, int(incoming.get(item_id, normalized.get(item_id, 0))))
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

static func add(inventory: Dictionary, item_id: String, amount: int = 1) -> bool:
	if not _ITEMS.has(item_id):
		return false
	inventory[item_id] = count(inventory, item_id) + maxi(1, amount)
	return true
