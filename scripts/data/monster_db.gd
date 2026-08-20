extends RefCounted

static var _MONSTERS: Dictionary = {
	"Luzik": {
		"id":1,"name":"Luzik","title":"Somaskan warstwowy","role":"Wsparcie / kontrola","types":["REZONANS"],"type":"REZONANS","max_hp":30,"attack":7,"defense":7,"speed":5,"capture_rate":0.30,"exp_yield":14,"rarity":"starter","habitat":["Vela"],"accent":Color("55e8de"),"description":"Stabilizuje pole i wzmacnia kolejne ruchy drużyny.",
		"moves":[
			{"name":"Impuls Warstwowy","power":7,"kind":"attack","move_type":"REZONANS","accuracy":0.96,"priority":0,"cost":1,"status":"unstable","status_chance":0.35,"note":"Może destabilizować pole przeciwnika."},
			{"name":"Mikroślizg","power":5,"kind":"attack","move_type":"PHYSICAL","accuracy":1.0,"priority":1,"cost":1,"status":"armor_break","status_chance":0.20,"note":"Szybki ruch naruszający osłonę."},
			{"name":"Synchronizacja","power":6,"kind":"heal","move_type":"SUPPORT","accuracy":1.0,"priority":0,"cost":1,"status":"stabilny","status_chance":1.0,"note":"Odzyskuje HP i stabilizuje pole."},
			{"name":"Osłona Fazowa","power":0,"kind":"guard","move_type":"SUPPORT","accuracy":1.0,"priority":1,"cost":1,"status":"guard","status_chance":1.0,"note":"Zmniejsza następne obrażenia."}
		]
	},
	"Bocznik": {
		"id":2,"name":"Bocznik","title":"Somaskan ścinający","role":"Szybki napastnik","types":["ŚLIZG"],"type":"ŚLIZG","max_hp":27,"attack":9,"defense":5,"speed":8,"capture_rate":0.30,"exp_yield":14,"rarity":"starter","habitat":["Vela"],"accent":Color("f0c967"),"description":"Pracuje na zmianie kierunku, szybkości i kontrach.",
		"moves":[
			{"name":"Cięcie Styczne","power":9,"kind":"attack","move_type":"PHYSICAL","accuracy":0.88,"priority":0,"cost":1,"status":"armor_break","status_chance":0.35,"note":"Mocne cięcie naruszające osłonę."},
			{"name":"Boczny Skok","power":6,"kind":"attack","move_type":"PHYSICAL","accuracy":0.96,"priority":1,"cost":1,"status":"stagger","status_chance":0.25,"note":"Szybki atak z flanki."},
			{"name":"Przeniesienie","power":5,"kind":"heal","move_type":"SUPPORT","accuracy":1.0,"priority":0,"cost":1,"status":"regen","status_chance":1.0,"note":"Odzyskuje HP i uruchamia regenerację."},
			{"name":"Kontra Ścinająca","power":0,"kind":"guard","move_type":"SUPPORT","accuracy":1.0,"priority":2,"cost":1,"status":"guard","status_chance":1.0,"note":"Redukuje kolejne obrażenia."}
		]
	},
	"Milimik": {
		"id":3,"name":"Milimik","title":"Somaskan mikroruchu","role":"Precyzja / osłabienie","types":["ŚLIZG"],"type":"ŚLIZG","max_hp":25,"attack":7,"defense":5,"speed":10,"capture_rate":0.40,"exp_yield":11,"rarity":"pospolity","habitat":["Obrzeża Veli","Gaj Szeptów"],"accent":Color("72d7b0"),"description":"Wykorzystuje niemal niewidoczne przesunięcia i serię drobnych przewag.",
		"moves":[
			{"name":"Mikrocięcie","power":5,"kind":"attack","move_type":"PHYSICAL","accuracy":1.0,"priority":2,"cost":1,"status":"bleed","status_chance":0.30,"note":"Precyzyjny ruch naruszający tkankę pola."},
			{"name":"Znikomy Krok","power":6,"kind":"attack","move_type":"PHYSICAL","accuracy":0.97,"priority":1,"cost":1,"status":"stagger","status_chance":0.25,"note":"Trudny do odczytania skok."},
			{"name":"Wyhamowanie","power":4,"kind":"heal","move_type":"SUPPORT","accuracy":1.0,"priority":1,"cost":1,"status":"focused","status_chance":1.0,"note":"Odzyskuje rytm i skupienie."},
			{"name":"Unik Warstwowy","power":0,"kind":"guard","move_type":"SUPPORT","accuracy":1.0,"priority":2,"cost":1,"status":"guard","status_chance":1.0,"note":"Krótka obrona ruchem."}
		]
	},
	"Pufek": {
		"id":4,"name":"Pufek","title":"Somaskan obciążenia","role":"Wytrzymałość / kontrola","types":["NAPIĘCIE"],"type":"NAPIĘCIE","max_hp":36,"attack":6,"defense":9,"speed":3,"capture_rate":0.36,"exp_yield":13,"rarity":"pospolity","habitat":["Obrzeża Veli","Szlak Rezonansu"],"accent":Color("e4a98d"),"description":"Gromadzi obciążenie, a potem oddaje je w krótkim impulsie.",
		"moves":[
			{"name":"Docisk","power":7,"kind":"attack","move_type":"PHYSICAL","accuracy":0.94,"priority":0,"cost":1,"status":"rooted","status_chance":0.30,"note":"Ciężki ruch ograniczający ucieczkę."},
			{"name":"Odciążenie","power":6,"kind":"attack","move_type":"REZONANS","accuracy":0.95,"priority":0,"cost":1,"status":"unstable","status_chance":0.25,"note":"Nagłe uwolnienie zgromadzonej energii."},
			{"name":"Miękki Powrót","power":7,"kind":"heal","move_type":"SUPPORT","accuracy":1.0,"priority":0,"cost":1,"status":"regen","status_chance":1.0,"note":"Powolna odbudowa kondycji."},
			{"name":"Puchowa Bariera","power":0,"kind":"guard","move_type":"SUPPORT","accuracy":1.0,"priority":1,"cost":1,"status":"guard","status_chance":1.0,"note":"Bardzo skuteczna osłona."}
		]
	},
	"Wahlik": {
		"id":5,"name":"Wahlik","title":"Somaskan oscylacyjny","role":"Oscylacja / presja","types":["OSC"],"type":"OSC","max_hp":23,"attack":6,"defense":5,"speed":6,"capture_rate":0.34,"exp_yield":12,"rarity":"pospolity","habitat":["Obrzeża Veli","Szlak Rezonansu"],"accent":Color("7ad56f"),"description":"Reaguje na ruch i łatwo wpada w serię oscylacji.",
		"moves":[
			{"name":"Oscylo-Cios","power":6,"kind":"attack","move_type":"OSC","accuracy":0.94,"priority":0,"cost":1,"status":"unstable","status_chance":0.20,"note":"Podstawowy ruch oscylacyjny."},
			{"name":"Wahnięcie","power":5,"kind":"attack","move_type":"OSC","accuracy":0.98,"priority":1,"cost":1,"status":"stagger","status_chance":0.20,"note":"Krótki skok fazowy."},
			{"name":"Drżenie","power":7,"kind":"attack","move_type":"REZONANS","accuracy":0.84,"priority":0,"cost":1,"status":"unstable","status_chance":0.45,"note":"Nieregularny impuls destabilizujący."},
			{"name":"Zastój","power":0,"kind":"guard","move_type":"SUPPORT","accuracy":1.0,"priority":1,"cost":1,"status":"guard","status_chance":1.0,"note":"Chwilowa ochrona."}
		]
	},
	"Kompasik": {
		"id":6,"name":"Kompasik","title":"Somaskan kierunkowy","role":"Nawigacja / oznaczenie","types":["KIERUNEK"],"type":"KIERUNEK","max_hp":28,"attack":6,"defense":6,"speed":8,"capture_rate":0.32,"exp_yield":14,"rarity":"niepospolity","habitat":["Szlak Rezonansu","Szkliste Wybrzeże"],"accent":Color("62a9df"),"description":"Wyczuwając gradient pola potrafi znaleźć najsłabszy kierunek obrony.",
		"moves":[
			{"name":"Wektor","power":7,"kind":"attack","move_type":"REZONANS","accuracy":0.96,"priority":0,"cost":1,"status":"marked","status_chance":0.35,"note":"Oznacza kierunek słabości."},
			{"name":"Zwrot Północny","power":6,"kind":"attack","move_type":"PHYSICAL","accuracy":0.98,"priority":1,"cost":1,"status":"stagger","status_chance":0.20,"note":"Szybki ruch kierunkowy."},
			{"name":"Kalibracja","power":5,"kind":"heal","move_type":"SUPPORT","accuracy":1.0,"priority":0,"cost":1,"status":"focused","status_chance":1.0,"note":"Kalibruje pole do następnego ruchu."},
			{"name":"Krąg Orientacji","power":0,"kind":"guard","move_type":"SUPPORT","accuracy":1.0,"priority":1,"cost":1,"status":"guard","status_chance":1.0,"note":"Ochrona przez zmianę osi."}
		]
	},
	"Srubik": {
		"id":7,"name":"Srubik","title":"Somaskan torsyjny","role":"Przełamanie / obrażenia","types":["TORSJA"],"type":"TORSJA","max_hp":31,"attack":9,"defense":7,"speed":4,"capture_rate":0.28,"exp_yield":16,"rarity":"niepospolity","habitat":["Jaskinia Echa","Gaj Szeptów"],"accent":Color("c28bd6"),"description":"Skręca warstwy pola i tworzy lokalne pęknięcia osłony.",
		"moves":[
			{"name":"Skręt","power":8,"kind":"attack","move_type":"PHYSICAL","accuracy":0.92,"priority":0,"cost":1,"status":"armor_break","status_chance":0.40,"note":"Silny ruch torsyjny."},
			{"name":"Gwint","power":7,"kind":"attack","move_type":"REZONANS","accuracy":0.94,"priority":0,"cost":1,"status":"unstable","status_chance":0.30,"note":"Wkręca impuls w pole przeciwnika."},
			{"name":"Rozprężenie","power":5,"kind":"heal","move_type":"SUPPORT","accuracy":1.0,"priority":0,"cost":1,"status":"stabilny","status_chance":1.0,"note":"Zmniejsza własne zakłócenie."},
			{"name":"Blokada Gwintu","power":0,"kind":"guard","move_type":"SUPPORT","accuracy":1.0,"priority":1,"cost":1,"status":"guard","status_chance":1.0,"note":"Zatrzymuje ruch warstw."}
		]
	},
	"Uczek": {
		"id":8,"name":"Uczek","title":"Somaskan obchodzący","role":"Unik / zakłócenie","types":["OBEJŚCIE"],"type":"OBEJŚCIE","max_hp":26,"attack":7,"defense":5,"speed":10,"capture_rate":0.31,"exp_yield":15,"rarity":"niepospolity","habitat":["Gaj Szeptów"],"accent":Color("78c58f"),"description":"Nie naciska na barierę; szuka drogi obok niej.",
		"moves":[
			{"name":"Obejście","power":7,"kind":"attack","move_type":"PHYSICAL","accuracy":0.98,"priority":1,"cost":1,"status":"armor_break","status_chance":0.25,"note":"Atakuje poza główną osią obrony."},
			{"name":"Łuk Pola","power":6,"kind":"attack","move_type":"REZONANS","accuracy":0.96,"priority":1,"cost":1,"status":"disrupted","status_chance":0.35,"note":"Zakłóca odpowiedź celu."},
			{"name":"Zejście z Linii","power":4,"kind":"heal","move_type":"SUPPORT","accuracy":1.0,"priority":2,"cost":1,"status":"focused","status_chance":1.0,"note":"Przywraca kontrolę przez zmianę pozycji."},
			{"name":"Pusty Kąt","power":0,"kind":"guard","move_type":"SUPPORT","accuracy":1.0,"priority":2,"cost":1,"status":"guard","status_chance":1.0,"note":"Unikowa osłona."}
		]
	},
	"Kotwiczek": {
		"id":9,"name":"Kotwiczek","title":"Somaskan stabilizujący","role":"Kotwica / obrona","types":["STABIL"],"type":"STABIL","max_hp":38,"attack":5,"defense":10,"speed":3,"capture_rate":0.26,"exp_yield":17,"rarity":"rzadki","habitat":["Szkliste Wybrzeże","Jaskinia Echa"],"accent":Color("809db7"),"description":"Stabilizuje lokalny układ i utrudnia przeciwnikowi zmianę warunków.",
		"moves":[
			{"name":"Kotwa","power":6,"kind":"attack","move_type":"PHYSICAL","accuracy":0.95,"priority":0,"cost":1,"status":"rooted","status_chance":0.50,"note":"Przytwierdza cel do pola."},
			{"name":"Ciężar Punktu","power":8,"kind":"attack","move_type":"PHYSICAL","accuracy":0.88,"priority":0,"cost":1,"status":"stagger","status_chance":0.35,"note":"Mocne, wolne uderzenie."},
			{"name":"Stabilizacja","power":7,"kind":"heal","move_type":"SUPPORT","accuracy":1.0,"priority":0,"cost":1,"status":"stabilny","status_chance":1.0,"note":"Odbudowuje i oczyszcza pole."},
			{"name":"Punkt Stały","power":0,"kind":"guard","move_type":"SUPPORT","accuracy":1.0,"priority":1,"cost":1,"status":"guard","status_chance":1.0,"note":"Bardzo mocna obrona."}
		]
	},
	"Nasuch": {
		"id":10,"name":"Nasuch","title":"Somaskan czujnikowy","role":"Analiza / reakcje","types":["CZUCIE"],"type":"CZUCIE","max_hp":27,"attack":6,"defense":6,"speed":9,"capture_rate":0.29,"exp_yield":16,"rarity":"rzadki","habitat":["Jaskinia Echa","Szkliste Wybrzeże"],"accent":Color("d2b36f"),"description":"Nasłuchuje zmian pola i reaguje zanim impuls osiągnie pełną siłę.",
		"moves":[
			{"name":"Nasłuch","power":6,"kind":"attack","move_type":"WAVE","accuracy":0.99,"priority":1,"cost":1,"status":"marked","status_chance":0.45,"note":"Wykrywa i oznacza słabość celu."},
			{"name":"Echo Czujnika","power":7,"kind":"attack","move_type":"REZONANS","accuracy":0.94,"priority":0,"cost":1,"status":"charged","status_chance":0.35,"note":"Wzbudza powracające echo."},
			{"name":"Cicha Kalibracja","power":5,"kind":"heal","move_type":"SUPPORT","accuracy":1.0,"priority":1,"cost":1,"status":"focused","status_chance":1.0,"note":"Odzyskuje HP i skupienie."},
			{"name":"Martwa Strefa","power":0,"kind":"guard","move_type":"SUPPORT","accuracy":1.0,"priority":2,"cost":1,"status":"guard","status_chance":1.0,"note":"Wycisza własny sygnał."}
		]
	},
	"Nucik": {
		"id":15,"name":"Nucik","title":"Somaskan harmoniczny","role":"Combo / balans","types":["FALA"],"type":"FALA","max_hp":29,"attack":7,"defense":6,"speed":7,"capture_rate":0.30,"exp_yield":14,"rarity":"starter","habitat":["Vela"],"accent":Color("b997ff"),"description":"Buduje kombinacje na rytmie, fali i zmianie fazy.",
		"moves":[
			{"name":"Ton Rezonansu","power":8,"kind":"attack","move_type":"WAVE","accuracy":0.92,"priority":0,"cost":1,"status":"soaked","status_chance":0.35,"note":"Fala przygotowująca reakcję."},
			{"name":"Echo Mantry","power":7,"kind":"attack","move_type":"REZONANS","accuracy":0.96,"priority":0,"cost":1,"status":"charged","status_chance":0.25,"note":"Powtarzalny impuls wzbudzający pole."},
			{"name":"Dostrojenie","power":6,"kind":"heal","move_type":"SUPPORT","accuracy":1.0,"priority":0,"cost":1,"status":"stabilny","status_chance":1.0,"note":"Przywraca HP i usuwa zakłócenia."},
			{"name":"Cisza Międzyfazowa","power":0,"kind":"guard","move_type":"SUPPORT","accuracy":1.0,"priority":1,"cost":1,"status":"guard","status_chance":1.0,"note":"Ogranicza siłę następnego trafienia."}
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
