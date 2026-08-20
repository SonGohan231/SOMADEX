extends RefCounted

static var _MONSTERS := {
	"Luzik": {
		"id": 1,
		"name": "Luzik",
		"title": "Somaskan warstwowy",
		"role": "Wsparcie / kontrola",
		"type": "REZONANS",
		"max_hp": 30,
		"accent": Color("55e8de"),
		"description": "Stabilizuje pole i wzmacnia kolejne ruchy drużyny.",
		"moves": [
			{"name":"Impuls Warstwowy", "power":7, "kind":"attack", "note":"Pewny atak rezonansowy."},
			{"name":"Mikroślizg", "power":5, "kind":"attack", "note":"Szybki, precyzyjny ruch."},
			{"name":"Synchronizacja", "power":6, "kind":"heal", "note":"Odzyskuje HP i stabilizuje rytm."},
			{"name":"Osłona Fazowa", "power":0, "kind":"guard", "note":"Zmniejsza następne obrażenia."}
		]
	},
	"Bocznik": {
		"id": 2,
		"name": "Bocznik",
		"title": "Somaskan ścinający",
		"role": "Szybki napastnik",
		"type": "ŚLIZG",
		"max_hp": 27,
		"accent": Color("f0c967"),
		"description": "Pracuje na zmianie kierunku, szybkości i kontrach.",
		"moves": [
			{"name":"Cięcie Styczne", "power":9, "kind":"attack", "note":"Mocny atak kontaktowy."},
			{"name":"Boczny Skok", "power":6, "kind":"attack", "note":"Szybki atak z flanki."},
			{"name":"Przeniesienie", "power":5, "kind":"heal", "note":"Odzyskuje część HP."},
			{"name":"Kontra Ścinająca", "power":0, "kind":"guard", "note":"Redukuje kolejne obrażenia."}
		]
	},
	"Nucik": {
		"id": 15,
		"name": "Nucik",
		"title": "Somaskan harmoniczny",
		"role": "Combo / balans",
		"type": "FALA",
		"max_hp": 29,
		"accent": Color("b997ff"),
		"description": "Buduje kombinacje na rytmie, fali i zmianie fazy.",
		"moves": [
			{"name":"Ton Rezonansu", "power":8, "kind":"attack", "note":"Fala o wysokiej stabilności."},
			{"name":"Echo Mantry", "power":7, "kind":"attack", "note":"Powtarzalny impuls falowy."},
			{"name":"Dostrojenie", "power":6, "kind":"heal", "note":"Przywraca HP przez synchronizację."},
			{"name":"Cisza Międzyfazowa", "power":0, "kind":"guard", "note":"Ogranicza siłę następnego trafienia."}
		]
	},
	"Wahlik": {
		"id": 5,
		"name": "Wahlik",
		"title": "Dziki Somaskan oscylacyjny",
		"role": "Dziki przeciwnik",
		"type": "OSC",
		"max_hp": 23,
		"accent": Color("7ad56f"),
		"description": "Reaguje na ruch i łatwo wpada w serię oscylacji.",
		"moves": [
			{"name":"Oscylo-Cios", "power":6, "kind":"attack", "note":"Podstawowy ruch Wahlików."},
			{"name":"Wahnięcie", "power":5, "kind":"attack", "note":"Krótki skok fazowy."},
			{"name":"Drżenie", "power":7, "kind":"attack", "note":"Nieregularny impuls."},
			{"name":"Zastój", "power":0, "kind":"guard", "note":"Chwilowa ochrona."}
		]
	}
}

static func get_monster(name: String) -> Dictionary:
	if not _MONSTERS.has(name):
		return _MONSTERS["Luzik"].duplicate(true)
	return _MONSTERS[name].duplicate(true)

static func starters() -> Array[String]:
	return ["Luzik", "Bocznik", "Nucik"]

static func first_zone_enemy() -> Dictionary:
	return get_monster("Wahlik")
