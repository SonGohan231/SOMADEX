extends RefCounted

const EVOLUTION = preload("res://scripts/data/evolution_db.gd")
const CATALOG = preload("res://scripts/data/creature_catalog.gd")

static var _MONSTERS: Dictionary = {
	"Luzik": _species(1, "Luzik", "Somaskan warstwowy", "Wsparcie / kontrola", "REZONANS", 30, 7, 7, 5, 0.30, 14, "starter", ["Vela"], Color("55e8de"), "Stabilizuje pole i wzmacnia kolejne ruchy drużyny.", [
		_move("Impuls Warstwowy", 7, "attack", "REZONANS", 0.96, 0, "unstable", 0.35),
		_move("Mikroślizg", 5, "attack", "PHYSICAL", 1.00, 1, "armor_break", 0.20),
		_move("Synchronizacja", 6, "heal", "SUPPORT", 1.00, 0, "stabilny", 1.00),
		_move("Osłona Fazowa", 0, "guard", "SUPPORT", 1.00, 1, "guard", 1.00)
	]),
	"Bocznik": _species(2, "Bocznik", "Somaskan ścinający", "Szybki napastnik", "ŚLIZG", 27, 9, 5, 8, 0.30, 14, "starter", ["Vela"], Color("f0c967"), "Pracuje na zmianie kierunku, szybkości i kontrach.", [
		_move("Cięcie Styczne", 9, "attack", "PHYSICAL", 0.88, 0, "armor_break", 0.35),
		_move("Boczny Skok", 6, "attack", "PHYSICAL", 0.96, 1, "stagger", 0.25),
		_move("Przeniesienie", 5, "heal", "SUPPORT", 1.00, 0, "regen", 1.00),
		_move("Kontra Ścinająca", 0, "guard", "SUPPORT", 1.00, 2, "guard", 1.00)
	]),
	"Milimik": _species(3, "Milimik", "Somaskan mikroruchu", "Precyzja / osłabienie", "ŚLIZG", 25, 7, 5, 10, 0.40, 11, "pospolity", ["Obrzeża Veli", "Gaj Szeptów"], Color("72d7b0"), "Wykorzystuje niemal niewidoczne przesunięcia i serię drobnych przewag.", [
		_move("Mikrocięcie", 5, "attack", "PHYSICAL", 1.00, 2, "bleed", 0.30),
		_move("Znikomy Krok", 6, "attack", "PHYSICAL", 0.97, 1, "stagger", 0.25),
		_move("Wyhamowanie", 4, "heal", "SUPPORT", 1.00, 1, "focused", 1.00),
		_move("Unik Warstwowy", 0, "guard", "SUPPORT", 1.00, 2, "guard", 1.00)
	]),
	"Pufek": _species(4, "Pufek", "Somaskan obciążenia", "Wytrzymałość / kontrola", "NAPIĘCIE", 36, 6, 9, 3, 0.36, 13, "pospolity", ["Obrzeża Veli", "Szlak Rezonansu"], Color("e4a98d"), "Gromadzi obciążenie, a potem oddaje je w krótkim impulsie.", [
		_move("Docisk", 7, "attack", "PHYSICAL", 0.94, 0, "rooted", 0.30),
		_move("Odciążenie", 6, "attack", "REZONANS", 0.95, 0, "unstable", 0.25),
		_move("Miękki Powrót", 7, "heal", "SUPPORT", 1.00, 0, "regen", 1.00),
		_move("Puchowa Bariera", 0, "guard", "SUPPORT", 1.00, 1, "guard", 1.00)
	]),
	"Wahlik": _species(5, "Wahlik", "Somaskan oscylacyjny", "Oscylacja / presja", "OSC", 23, 6, 5, 6, 0.34, 12, "pospolity", ["Obrzeża Veli", "Szlak Rezonansu"], Color("7ad56f"), "Reaguje na ruch i łatwo wpada w serię oscylacji.", [
		_move("Oscylo-Cios", 6, "attack", "OSC", 0.94, 0, "unstable", 0.20),
		_move("Wahnięcie", 5, "attack", "OSC", 0.98, 1, "stagger", 0.20),
		_move("Drżenie", 7, "attack", "REZONANS", 0.84, 0, "unstable", 0.45),
		_move("Zastój", 0, "guard", "SUPPORT", 1.00, 1, "guard", 1.00)
	]),
	"Kompasik": _species(6, "Kompasik", "Somaskan kierunkowy", "Nawigacja / oznaczenie", "KIERUNEK", 28, 6, 6, 8, 0.32, 14, "niepospolity", ["Szlak Rezonansu", "Szkliste Wybrzeże"], Color("62a9df"), "Wyczuwa gradient pola i znajduje słaby kierunek obrony.", [
		_move("Wektor", 7, "attack", "REZONANS", 0.96, 0, "marked", 0.35),
		_move("Zwrot Północny", 6, "attack", "PHYSICAL", 0.98, 1, "stagger", 0.20),
		_move("Kalibracja", 5, "heal", "SUPPORT", 1.00, 0, "focused", 1.00),
		_move("Krąg Orientacji", 0, "guard", "SUPPORT", 1.00, 1, "guard", 1.00)
	]),
	"Srubik": _species(7, "Srubik", "Somaskan torsyjny", "Przełamanie / obrażenia", "TORSJA", 31, 9, 7, 4, 0.28, 16, "niepospolity", ["Jaskinia Echa", "Gaj Szeptów"], Color("c28bd6"), "Skręca warstwy pola i tworzy lokalne pęknięcia osłony.", [
		_move("Skręt", 8, "attack", "PHYSICAL", 0.92, 0, "armor_break", 0.40),
		_move("Gwint", 7, "attack", "REZONANS", 0.94, 0, "unstable", 0.30),
		_move("Rozprężenie", 5, "heal", "SUPPORT", 1.00, 0, "stabilny", 1.00),
		_move("Blokada Gwintu", 0, "guard", "SUPPORT", 1.00, 1, "guard", 1.00)
	]),
	"Uczek": _species(8, "Uczek", "Somaskan obchodzący", "Unik / zakłócenie", "OBEJŚCIE", 26, 7, 5, 10, 0.31, 15, "niepospolity", ["Gaj Szeptów"], Color("78c58f"), "Nie naciska na barierę; szuka drogi obok niej.", [
		_move("Obejście", 7, "attack", "PHYSICAL", 0.98, 1, "armor_break", 0.25),
		_move("Łuk Pola", 6, "attack", "REZONANS", 0.96, 1, "disrupted", 0.35),
		_move("Zejście z Linii", 4, "heal", "SUPPORT", 1.00, 2, "focused", 1.00),
		_move("Pusty Kąt", 0, "guard", "SUPPORT", 1.00, 2, "guard", 1.00)
	]),
	"Kotwiczek": _species(9, "Kotwiczek", "Somaskan stabilizujący", "Kotwica / obrona", "STABIL", 38, 5, 10, 3, 0.26, 17, "rzadki", ["Szkliste Wybrzeże", "Jaskinia Echa"], Color("809db7"), "Stabilizuje lokalny układ i utrudnia zmianę warunków.", [
		_move("Kotwa", 6, "attack", "PHYSICAL", 0.95, 0, "rooted", 0.50),
		_move("Ciężar Punktu", 8, "attack", "PHYSICAL", 0.88, 0, "stagger", 0.35),
		_move("Stabilizacja", 7, "heal", "SUPPORT", 1.00, 0, "stabilny", 1.00),
		_move("Punkt Stały", 0, "guard", "SUPPORT", 1.00, 1, "guard", 1.00)
	]),
	"Nasuch": _species(10, "Nasuch", "Somaskan czujnikowy", "Analiza / reakcje", "CZUCIE", 27, 6, 6, 9, 0.29, 16, "rzadki", ["Jaskinia Echa", "Szkliste Wybrzeże"], Color("d2b36f"), "Nasłuchuje zmian pola i reaguje zanim impuls osiągnie pełną siłę.", [
		_move("Nasłuch", 6, "attack", "WAVE", 0.99, 1, "marked", 0.45),
		_move("Echo Czujnika", 7, "attack", "REZONANS", 0.94, 0, "charged", 0.35),
		_move("Cicha Kalibracja", 5, "heal", "SUPPORT", 1.00, 1, "focused", 1.00),
		_move("Martwa Strefa", 0, "guard", "SUPPORT", 1.00, 2, "guard", 1.00)
	]),
	"Nucik": _species(15, "Nucik", "Somaskan harmoniczny", "Combo / balans", "FALA", 29, 7, 6, 7, 0.30, 14, "starter", ["Vela"], Color("b997ff"), "Buduje kombinacje na rytmie, fali i zmianie fazy.", [
		_move("Ton Rezonansu", 8, "attack", "WAVE", 0.92, 0, "soaked", 0.35),
		_move("Echo Mantry", 7, "attack", "REZONANS", 0.96, 0, "charged", 0.25),
		_move("Dostrojenie", 6, "heal", "SUPPORT", 1.00, 0, "stabilny", 1.00),
		_move("Cisza Międzyfazowa", 0, "guard", "SUPPORT", 1.00, 1, "guard", 1.00)
	])
}

static func _species(id: int, name: String, title: String, role: String, type_id: String, max_hp: int, attack: int, defense: int, speed: int, capture_rate: float, exp_yield: int, rarity: String, habitat: Array, accent: Color, description: String, moves: Array) -> Dictionary:
	return {"id":id,"name":name,"title":title,"role":role,"types":[type_id],"type":type_id,"max_hp":max_hp,"attack":attack,"defense":defense,"speed":speed,"capture_rate":capture_rate,"exp_yield":exp_yield,"rarity":rarity,"habitat":habitat,"accent":accent,"description":description,"moves":moves}

static func _move(name: String, power: int, kind: String, move_type: String, accuracy: float, priority: int, status: String, status_chance: float) -> Dictionary:
	return {"name":name,"power":power,"kind":kind,"move_type":move_type,"accuracy":accuracy,"priority":priority,"cost":1,"status":status,"status_chance":status_chance,"note":""}

static func has_monster(name: String) -> bool:
	if _MONSTERS.has(name):
		return true
	return not EVOLUTION.form_info(name).is_empty()

static func get_monster(name: String) -> Dictionary:
	if _MONSTERS.has(name):
		return (_MONSTERS[name] as Dictionary).duplicate(true)
	var info: Dictionary = EVOLUTION.form_info(name)
	if info.is_empty():
		return (_MONSTERS["Luzik"] as Dictionary).duplicate(true)
	var canonical: String = str(info.get("name", name))
	var base_name: String = str(info.get("base", canonical))
	var base_data: Dictionary = _implemented_casefold(base_name)
	if not base_data.is_empty():
		return _evolved_from(base_data, canonical, info)
	return _generated_catalog_form(canonical, info)

static func get_by_id(monster_id: int) -> Dictionary:
	for monster_name: String in all_names():
		var data: Dictionary = get_monster(monster_name)
		if int(data.get("id", -1)) == monster_id:
			return data
	return {}

static func all_names() -> Array[String]:
	var names: Array[String] = []
	for family: Dictionary in CATALOG.all_families():
		for raw_name: Variant in family.get("forms", []) as Array:
			var canonical: String = EVOLUTION.canonical_name(str(raw_name))
			if not canonical.is_empty() and not names.has(canonical):
				names.append(canonical)
	return names

static func starters() -> Array[String]:
	return ["Luzik", "Bocznik", "Nucik"]

static func first_zone_enemy() -> Dictionary:
	return get_monster("Wahlik")

static func _implemented_casefold(name: String) -> Dictionary:
	var target: String = name.to_lower()
	for raw_key: Variant in _MONSTERS.keys():
		var key: String = str(raw_key)
		if key.to_lower() == target:
			return (_MONSTERS[key] as Dictionary).duplicate(true)
	return {}

static func _evolved_from(base_data: Dictionary, canonical: String, info: Dictionary) -> Dictionary:
	var stage: int = maxi(1, int(info.get("stage", 1)))
	var family_id: int = maxi(1, int(info.get("family_id", 1)))
	var result: Dictionary = base_data.duplicate(true)
	result["id"] = family_id if stage == 1 else family_id * 10 + stage
	result["name"] = canonical
	result["max_hp"] = int(base_data.get("max_hp", 20)) + (stage - 1) * 8
	result["attack"] = int(base_data.get("attack", 6)) + (stage - 1) * 2
	result["defense"] = int(base_data.get("defense", 6)) + (stage - 1) * 2
	result["speed"] = int(base_data.get("speed", 6)) + (stage - 1) * 2
	result["capture_rate"] = maxf(0.12, float(base_data.get("capture_rate", 0.30)) - float(stage - 1) * 0.04)
	result["exp_yield"] = int(base_data.get("exp_yield", 12)) + (stage - 1) * 7
	result["rarity"] = "ewolucja I" if stage == 2 else "forma finalna"
	result["title"] = "%s · %s" % ["Ewolucja I" if stage == 2 else "Forma finalna", _pretty_theme(str(info.get("theme", "Somaskan")))]
	result["description"] = "%s. Rozwinięta forma rodziny %s." % [canonical, _pretty_theme(str(info.get("theme", "")))]
	var evolved_moves: Array = []
	for raw_move: Variant in base_data.get("moves", []) as Array:
		var move_data: Dictionary = (raw_move as Dictionary).duplicate(true)
		var kind: String = str(move_data.get("kind", "attack"))
		if kind in ["attack", "heal"]:
			move_data["power"] = int(move_data.get("power", 0)) + (stage - 1) * 2
		move_data["status_chance"] = minf(1.0, float(move_data.get("status_chance", 0.0)) + float(stage - 1) * 0.05)
		evolved_moves.append(move_data)
	result["moves"] = evolved_moves
	return result

static func _generated_catalog_form(canonical: String, info: Dictionary) -> Dictionary:
	var family_id: int = maxi(1, int(info.get("family_id", 1)))
	var stage: int = maxi(1, int(info.get("stage", 1)))
	var theme: String = _pretty_theme(str(info.get("theme", "Rezonans")))
	var seed: int = family_id * 17
	var base_hp: int = 24 + seed % 9
	var base_attack: int = 6 + seed % 4
	var base_defense: int = 5 + int(seed / 3) % 5
	var base_speed: int = 5 + int(seed / 5) % 6
	var stage_bonus: int = (stage - 1) * 3
	return {
		"id": family_id if stage == 1 else family_id * 10 + stage,
		"name": canonical,
		"title": "%s · %s" % ["Somaskan" if stage == 1 else ("Ewolucja I" if stage == 2 else "Forma finalna"), theme],
		"role": "Adaptacja / rezonans",
		"types": ["REZONANS"],
		"type": "REZONANS",
		"max_hp": base_hp + stage_bonus * 2,
		"attack": base_attack + stage_bonus,
		"defense": base_defense + stage_bonus,
		"speed": base_speed + stage_bonus,
		"capture_rate": maxf(0.14, 0.34 - float(stage - 1) * 0.05),
		"exp_yield": 12 + family_id % 7 + (stage - 1) * 7,
		"rarity": "katalog" if stage == 1 else ("ewolucja I" if stage == 2 else "forma finalna"),
		"habitat": ["Poza Velą"],
		"accent": Color.from_hsv(fmod(float(family_id) * 0.071, 1.0), 0.55, 0.90),
		"description": "%s — rodzina %d: %s." % [canonical, family_id, theme],
		"moves": [
			_move("Impuls Rodziny", 6 + stage_bonus, "attack", "REZONANS", 0.95, 0, "unstable", 0.25 + float(stage - 1) * 0.05),
			_move("Ruch Kierunkowy", 5 + stage_bonus, "attack", "PHYSICAL", 0.98, 1, "marked", 0.20 + float(stage - 1) * 0.05),
			_move("Regeneracja Pola", 5 + stage_bonus, "heal", "SUPPORT", 1.00, 0, "regen", 1.00),
			_move("Osłona Rodziny", 0, "guard", "SUPPORT", 1.00, 1, "guard", 1.00)
		]
	}

static func _pretty_theme(theme: String) -> String:
	return theme.replace("_", " ")
