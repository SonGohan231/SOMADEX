extends RefCounted

static var _MONSTERS: Dictionary = {
	"Luzik": {
		"id": 1,
		"name": "Luzik",
		"title": "Somaskan warstwowy",
		"role": "Wsparcie / kontrola",
		"types": ["REZONANS"],
		"type": "REZONANS",
		"max_hp": 30,
		"attack": 7,
		"defense": 7,
		"speed": 5,
		"capture_rate": 0.30,
		"exp_yield": 14,
		"rarity": "starter",
		"habitat": ["Vela"],
		"accent": Color("55e8de"),
		"description": "Stabilizuje pole i wzmacnia kolejne ruchy drużyny.",
		"moves": [
			{"name": "Impuls Warstwowy", "power": 7, "kind": "attack", "move_type": "REZONANS", "accuracy": 0.96, "priority": 0, "cost": 1, "status": "unstable", "status_chance": 0.35, "note": "Może destabilizować pole przeciwnika."},
			{"name": "Mikroślizg", "power": 5, "kind": "attack", "move_type": "PHYSICAL", "accuracy": 1.00, "priority": 1, "cost": 1, "status": "armor_break", "status_chance": 0.20, "note": "Szybki ruch mogący naruszyć osłonę."},
			{"name": "Synchronizacja", "power": 6, "kind": "heal", "move_type": "SUPPORT", "accuracy": 1.00, "priority": 0, "cost": 1, "status": "stabilny", "status_chance": 1.00, "note": "Odzyskuje HP i usuwa destabilizację."},
			{"name": "Osłona Fazowa", "power": 0, "kind": "guard", "move_type": "SUPPORT", "accuracy": 1.00, "priority": 1, "cost": 1, "status": "guard", "status_chance": 1.00, "note": "Zmniejsza następne obrażenia."}
		]
	},
	"Bocznik": {
		"id": 2,
		"name": "Bocznik",
		"title": "Somaskan ścinający",
		"role": "Szybki napastnik",
		"types": ["ŚLIZG"],
		"type": "ŚLIZG",
		"max_hp": 27,
		"attack": 9,
		"defense": 5,
		"speed": 8,
		"capture_rate": 0.30,
		"exp_yield": 14,
		"rarity": "starter",
		"habitat": ["Vela"],
		"accent": Color("f0c967"),
		"description": "Pracuje na zmianie kierunku, szybkości i kontrach.",
		"moves": [
			{"name": "Cięcie Styczne", "power": 9, "kind": "attack", "move_type": "PHYSICAL", "accuracy": 0.88, "priority": 0, "cost": 1, "status": "armor_break", "status_chance": 0.35, "note": "Mocny atak z szansą przełamania osłony."},
			{"name": "Boczny Skok", "power": 6, "kind": "attack", "move_type": "PHYSICAL", "accuracy": 0.96, "priority": 1, "cost": 1, "status": "stagger", "status_chance": 0.25, "note": "Szybki atak z flanki."},
			{"name": "Przeniesienie", "power": 5, "kind": "heal", "move_type": "SUPPORT", "accuracy": 1.00, "priority": 0, "cost": 1, "status": "regen", "status_chance": 1.00, "note": "Odzyskuje część HP i uruchamia regenerację."},
			{"name": "Kontra Ścinająca", "power": 0, "kind": "guard", "move_type": "SUPPORT", "accuracy": 1.00, "priority": 2, "cost": 1, "status": "guard", "status_chance": 1.00, "note": "Redukuje kolejne obrażenia."}
		]
	},
	"Wahlik": {
		"id": 5,
		"name": "Wahlik",
		"title": "Dziki Somaskan oscylacyjny",
		"role": "Oscylacja / presja",
		"types": ["OSC"],
		"type": "OSC",
		"max_hp": 23,
		"attack": 6,
		"defense": 5,
		"speed": 6,
		"capture_rate": 0.34,
		"exp_yield": 12,
		"rarity": "pospolity",
		"habitat": ["Vela i Obrzeża", "Szlak Rezonansu"],
		"accent": Color("7ad56f"),
		"description": "Reaguje na ruch i łatwo wpada w serię oscylacji.",
		"moves": [
			{"name": "Oscylo-Cios", "power": 6, "kind": "attack", "move_type": "OSC", "accuracy": 0.94, "priority": 0, "cost": 1, "status": "unstable", "status_chance": 0.20, "note": "Podstawowy ruch oscylacyjny."},
			{"name": "Wahnięcie", "power": 5, "kind": "attack", "move_type": "OSC", "accuracy": 0.98, "priority": 1, "cost": 1, "status": "stagger", "status_chance": 0.20, "note": "Krótki skok fazowy."},
			{"name": "Drżenie", "power": 7, "kind": "attack", "move_type": "REZONANS", "accuracy": 0.84, "priority": 0, "cost": 1, "status": "unstable", "status_chance": 0.45, "note": "Nieregularny impuls destabilizujący."},
			{"name": "Zastój", "power": 0, "kind": "guard", "move_type": "SUPPORT", "accuracy": 1.00, "priority": 1, "cost": 1, "status": "guard", "status_chance": 1.00, "note": "Chwilowa ochrona."}
		]
	},
	"Nucik": {
		"id": 15,
		"name": "Nucik",
		"title": "Somaskan harmoniczny",
		"role": "Combo / balans",
		"types": ["FALA"],
		"type": "FALA",
		"max_hp": 29,
		"attack": 7,
		"defense": 6,
		"speed": 7,
		"capture_rate": 0.30,
		"exp_yield": 14,
		"rarity": "starter",
		"habitat": ["Vela"],
		"accent": Color("b997ff"),
		"description": "Buduje kombinacje na rytmie, fali i zmianie fazy.",
		"moves": [
			{"name": "Ton Rezonansu", "power": 8, "kind": "attack", "move_type": "WAVE", "accuracy": 0.92, "priority": 0, "cost": 1, "status": "soaked", "status_chance": 0.35, "note": "Fala może nasycić pole i przygotować reakcję."},
			{"name": "Echo Mantry", "power": 7, "kind": "attack", "move_type": "REZONANS", "accuracy": 0.96, "priority": 0, "cost": 1, "status": "charged", "status_chance": 0.25, "note": "Powtarzalny impuls wzbudzający pole."},
			{"name": "Dostrojenie", "power": 6, "kind": "heal", "move_type": "SUPPORT", "accuracy": 1.00, "priority": 0, "cost": 1, "status": "stabilny", "status_chance": 1.00, "note": "Przywraca HP i usuwa zakłócenia."},
			{"name": "Cisza Międzyfazowa", "power": 0, "kind": "guard", "move_type": "SUPPORT", "accuracy": 1.00, "priority": 1, "cost": 1, "status": "guard", "status_chance": 1.00, "note": "Ogranicza siłę następnego trafienia."}
		]
	}
}

static func has_monster(name: String) -> bool:
	return _MONSTERS.has(name)

static func get_monster(name: String) -> Dictionary:
	if not _MONSTERS.has(name):
		return (_MONSTERS["Luzik"] as Dictionary).duplicate(true)
	return (_MONSTERS[name] as Dictionary).duplicate(true)

static func get_by_id(monster_id: int) -> Dictionary:
	for name: String in all_names():
		var data: Dictionary = _MONSTERS[name] as Dictionary
		if int(data.get("id", -1)) == monster_id:
			return data.duplicate(true)
	return {}

static func all_names() -> Array[String]:
	var names: Array[String] = []
	for key: Variant in _MONSTERS.keys():
		names.append(str(key))
	names.sort_custom(func(a: String, b: String) -> bool:
		return int((_MONSTERS[a] as Dictionary)["id"]) < int((_MONSTERS[b] as Dictionary)["id"])
	)
	return names

static func starters() -> Array[String]:
	return ["Luzik", "Bocznik", "Nucik"]

static func first_zone_enemy() -> Dictionary:
	return get_monster("Wahlik")
