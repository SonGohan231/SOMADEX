extends RefCounted

const NODES_PER_PATH: int = 20

static var PATHS: Array[String] = ["tactician", "guardian", "researcher", "technician", "vanguard"]
static var _NAMES: Dictionary = {
	"tactician": ["Ocena Tempa", "Szybka Komenda", "Czytanie Pola", "Kąt Kontry", "Zmiana Rytmu", "Plan B", "Sekwencja", "Przewaga Pozycji", "Rezerwa Taktyczna", "Analiza Tury", "Łańcuch Kontr", "Zmiana Priorytetu", "Presja Decyzji", "Plan Warstwowy", "Okno Reakcji", "Dominacja Tempa", "Mistrz Kombinacji", "Podwójny Plan", "Czytanie Intencji", "PRZEWIDZENIE"],
	"guardian": ["Pierwsza Więź", "Spokojny Głos", "Opieka Polowa", "Wspólny Rytm", "Lepsze Leczenie", "Bezpieczny Powrót", "Stała Więź", "Ochrona Partnera", "Wzmocniona Regeneracja", "Nauka Przez Więź", "Osłona Instynktu", "Długi Rezonans", "Ewolucyjna Opieka", "Wspólna Odporność", "Powrót Do Formy", "Strażnik Drużyny", "Głęboka Więź", "Ochrona Krytyczna", "Mistrz Opieki", "PEŁNA SYNCHRONIZACJA"],
	"researcher": ["Notatnik Terenowy", "Ślad Rzadkości", "Skan Podstawowy", "Czuły Moduł", "Lepszy Chwyt", "Znaki Środowiska", "Ukryty Przedmiot", "Skan Ruchów", "Mapa Habitatów", "Analiza Odporności", "Precyzyjny Chwyt", "Ścieżka Sekretna", "Skan Pasywki", "Rzadkie Echo", "Zaawansowany SOMADEX", "Analiza Kombinacji", "Łowca Unikatów", "Pełny Profil", "Mistrz Ekspedycji", "TOTALNA ANALIZA"],
	"technician": ["Kalibracja Gadżetów", "Oszczędny Impuls", "Naprawa Polowa", "Moduł Pomocniczy", "Wzmocnione Przedmioty", "Prosta Pułapka", "Stabilny Generator", "Recykling Materiałów", "Ładunek Rezerwowy", "Modyfikacja Modułu", "Pole Zakłócające", "Precyzyjny Dozownik", "Zaawansowany Crafting", "Generator Wielofazowy", "Podwójne Zasilanie", "Automatyczna Bariera", "Mistrz Urządzeń", "Sieć Generatorów", "Inżynier Rezonansu", "NADRZĘDNY GENERATOR"],
	"vanguard": ["Postawa Frontowa", "Szybki Unik", "Przechwyt Podstawowy", "Tarcza Polowa", "Odporna Pozycja", "Kontra Trenera", "Ochrona Partnera", "Manewr Awaryjny", "Stabilność Bojowa", "Przechwyt Impulsu", "Tarcza Rezonansowa", "Ofensywny Gadżet", "Wzmocniony Unik", "Linia Obrony", "Kontra Urządzeniem", "Niezłomna Koncentracja", "Awangarda Drużyny", "Przejęcie Uderzenia", "Mistrz Frontu", "NIEZŁOMNY REZONANS"]
}
static var _LEVELS: Array[int] = [1, 3, 5, 7, 10, 12, 14, 16, 20, 22, 24, 26, 30, 33, 36, 39, 40, 44, 47, 50]

static func path_ids() -> Array[String]:
	var result: Array[String] = []
	for path_id: String in PATHS:
		result.append(path_id)
	return result

static func node_id(path_id: String, index: int) -> String:
	return "%s_%02d" % [path_id, clampi(index, 1, NODES_PER_PATH)]

static func node(path_id: String, index: int) -> Dictionary:
	if not PATHS.has(path_id):
		return {}
	if index < 1 or index > NODES_PER_PATH:
		return {}
	var names: Array = _NAMES.get(path_id, []) as Array
	if names.size() < NODES_PER_PATH:
		return {}
	var effects: Dictionary = _effect_for(path_id, index)
	return {
		"id": node_id(path_id, index),
		"path_id": path_id,
		"index": index,
		"name": str(names[index - 1]),
		"required_level": int(_LEVELS[index - 1]),
		"tier": 1 + int((index - 1) / 4),
		"ultimate": index == NODES_PER_PATH,
		"effects": effects,
		"description": _description(path_id, index, effects)
	}

static func all_nodes() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for path_id: String in PATHS:
		for index: int in range(1, NODES_PER_PATH + 1):
			result.append(node(path_id, index))
	return result

static func nodes_for_path(path_id: String) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if not PATHS.has(path_id):
		return result
	for index: int in range(1, NODES_PER_PATH + 1):
		result.append(node(path_id, index))
	return result

static func next_node(path_id: String, investment: int) -> Dictionary:
	if investment >= NODES_PER_PATH:
		return {}
	return node(path_id, clampi(investment + 1, 1, NODES_PER_PATH))

static func can_unlock(path_id: String, investment: int, trainer_level: int) -> bool:
	var candidate: Dictionary = next_node(path_id, investment)
	if candidate.is_empty():
		return false
	return trainer_level >= int(candidate.get("required_level", 1))

static func aggregate(talents: Dictionary) -> Dictionary:
	var totals: Dictionary = {
		"attack_bonus": 0,
		"heal_bonus": 0,
		"max_hp_bonus": 0,
		"capture_bonus": 0.0,
		"item_heal_bonus": 0,
		"escape_bonus": 0.0,
		"stability_resist": 0.0,
		"rare_encounter_bonus": 0.0,
		"hidden_find_bonus": 0.0,
		"combo_bonus": 0,
		"counter_bonus": 0,
		"gadget_power_bonus": 0,
		"crafting_bonus": 0,
		"bond_xp_bonus": 0.0,
		"focus_efficiency": 0
	}
	for path_id: String in PATHS:
		var investment: int = clampi(int(talents.get(path_id, 0)), 0, NODES_PER_PATH)
		for index: int in range(1, investment + 1):
			var talent_node: Dictionary = node(path_id, index)
			var effects: Dictionary = talent_node.get("effects", {}) as Dictionary
			for raw_key: Variant in effects.keys():
				var key: String = str(raw_key)
				var value: Variant = effects.get(raw_key)
				if totals.has(key):
					if typeof(totals.get(key)) == TYPE_FLOAT or typeof(value) == TYPE_FLOAT:
						totals[key] = float(totals.get(key, 0.0)) + float(value)
					else:
						totals[key] = int(totals.get(key, 0)) + int(value)
				else:
					totals[key] = value
	return totals

static func _effect_for(path_id: String, index: int) -> Dictionary:
	match path_id:
		"tactician":
			if index == 20:
				return {"combo_bonus": 2, "counter_bonus": 2, "focus_efficiency": 1}
			if [1, 5, 9, 13, 17].has(index):
				return {"attack_bonus": 1}
			if [4, 8, 12, 16].has(index):
				return {"counter_bonus": 1}
			if [7, 11, 15, 18].has(index):
				return {"combo_bonus": 1}
			if index % 2 == 0:
				return {"combo_bonus": 1}
			return {}
		"guardian":
			if index == 20:
				return {"max_hp_bonus": 3, "heal_bonus": 3, "bond_xp_bonus": 0.15}
			if [1, 5, 9, 13, 17].has(index):
				return {"max_hp_bonus": 1}
			if [2, 6, 10, 14, 18].has(index):
				return {"heal_bonus": 1}
			if [4, 8, 12, 16].has(index):
				return {"bond_xp_bonus": 0.05}
			if index % 3 == 0:
				return {"max_hp_bonus": 1}
			return {}
		"researcher":
			if index == 20:
				return {"capture_bonus": 0.08, "rare_encounter_bonus": 0.08, "hidden_find_bonus": 0.10}
			if [1, 5, 9, 13, 17].has(index):
				return {"capture_bonus": 0.02}
			if [2, 6, 10, 14, 18].has(index):
				return {"rare_encounter_bonus": 0.02}
			if [3, 7, 11, 15, 19].has(index):
				return {"hidden_find_bonus": 0.03}
			return {}
		"technician":
			if index == 20:
				return {"gadget_power_bonus": 3, "crafting_bonus": 3, "focus_efficiency": 1}
			if [1, 5, 9, 13, 17].has(index):
				return {"item_heal_bonus": 1}
			if [2, 6, 10, 14, 18].has(index):
				return {"gadget_power_bonus": 1}
			if [3, 7, 11, 15, 19].has(index):
				return {"crafting_bonus": 1}
			return {}
		"vanguard":
			if index == 20:
				return {"stability_resist": 0.10, "counter_bonus": 2, "focus_efficiency": 1}
			if [1, 5, 9, 13, 17].has(index):
				return {"escape_bonus": 0.02}
			if [2, 6, 10, 14, 18].has(index):
				return {"stability_resist": 0.02}
			if [4, 8, 12, 16].has(index):
				return {"counter_bonus": 1}
			return {}
	return {}

static func _description(path_id: String, index: int, effects: Dictionary) -> String:
	if index == 20:
		match path_id:
			"tactician":
				return "Ultimate: ujawnia zamiar przeciwnika i maksymalizuje okno reakcji."
			"guardian":
				return "Ultimate: pełna synchronizacja wzmacnia więź, leczenie i odporność partnera."
			"researcher":
				return "Ultimate: pełna analiza ujawnia profil celu i maksymalizuje premie eksploracyjne."
			"technician":
				return "Ultimate: nadrzędny generator wzmacnia gadżety i zarządzanie Focus."
			"vanguard":
				return "Ultimate: niezłomny rezonans zwiększa przechwyt i odporność koncentracji."
	var parts: Array[String] = []
	for raw_key: Variant in effects.keys():
		var value: Variant = effects.get(raw_key)
		if typeof(value) == TYPE_FLOAT:
			parts.append("%s %+d%%" % [str(raw_key), int(round(float(value) * 100.0))])
		else:
			if int(value) != 0:
				parts.append("%s %+d" % [str(raw_key), int(value)])
	var suffix: String = ""
	if not parts.is_empty():
		suffix = " " + ", ".join(parts)
	return "Rozwija ścieżkę %s.%s" % [path_id.to_upper(), suffix]
