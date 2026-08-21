extends RefCounted

const TRAINERS = preload("res://scripts/data/campaign_trainer_db.gd")

static var _STORY_NPCS: Array[Dictionary] = [
	{"id":"orin_archivist","zone":"orin_gate","tile":[4,11],"name":"Alda","role":"archiwistka Bramy","color":"687ba0","flag":"talked_orin_archivist","first":"Brama Orin była kiedyś granicą starego systemu rezonansu. Dalej każde miejsce ma własne zasady pola.","again":"Zapisuj, co działa na różnych biomach. Siła bez kontekstu szybko przestaje wystarczać."},
	{"id":"orin_medic","zone":"orin_gate","tile":[10,15],"name":"Jem","role":"medyk","color":"6aa783","flag":"talked_orin_medic","first":"Na mokradłach status MOKRY bywa początkiem całego łańcucha reakcji.","again":"Przygotuj ruchy elektryczne albo chłód, jeśli chcesz wykorzystać środowisko."},
	{"id":"marea_sailor","zone":"marea","tile":[4,11],"name":"Rilo","role":"żeglarz","color":"4d86a8","flag":"talked_marea_sailor","first":"Marea żyje z przypływów. Somaskany z raf pojawiają się tu w innych proporcjach niż pod Velą.","again":"Rafa Koral leży daleko na wschodzie regionu. Wrócisz do morza znacznie później."},
	{"id":"marea_engineer","zone":"marea","tile":[10,15],"name":"Ossa","role":"inżynierka portu","color":"a17a4d","flag":"talked_marea_engineer","first":"Linia Ferrum jest czynna. Zabierz materiały — w warsztatach zrobisz z nich prawdziwe gadżety.","again":"Technik nie jest ścieżką od większych liczb. Zmienia to, jakie narzędzia możesz przygotować."},
	{"id":"ferrum_foreman","zone":"ferrum","tile":[4,11],"name":"Korn","role":"mistrz warsztatu","color":"8b6b51","flag":"talked_ferrum_foreman","first":"Elektrownia Cewkowa destabilizuje całe miasto. Zanim ruszysz w góry, zatrzymaj źródło przeciążenia.","again":"Konstrukt reaguje na zakłócenia i kombinacje statusów lepiej niż na bezmyślne uderzanie."},
	{"id":"ferrum_crafter","zone":"ferrum","tile":[10,15],"name":"Vika","role":"rzemieślniczka","color":"b58955","flag":"talked_ferrum_crafter","first":"Odłamki stopu, cewki i kryształy to nie śmieci. W SOMADEX materiały mają konkretne zastosowania.","again":"Sprawdź CRAFTING w menu. Receptury Technika otwierają się razem z jego rozwojem."},
	{"id":"nivra_sage","zone":"nivra","tile":[4,11],"name":"Hev","role":"przewodnik górski","color":"71869b","flag":"talked_nivra_sage","first":"Nivra uczy cierpliwości. Głęboki Uskok kończy ten etap drogi, ale walka w nim jest długa.","again":"Nie zabieraj sześciu napastników. Wysokie poziomy zaczynają karać brak ról w drużynie."},
	{"id":"nivra_keeper","zone":"nivra","tile":[10,15],"name":"Meya","role":"opiekunka schronu","color":"7f9f91","flag":"talked_nivra_keeper","first":"Jeśli twój build trenera ma dziurę, góry ją pokażą. Ekwipunek może ją zasłonić albo pogłębić.","again":"Sześć slotów sprzętu ma tworzyć styl gry, nie ranking rzadkości."},
	{"id":"lumen_reader","zone":"lumen","tile":[4,11],"name":"Siv","role":"czytelnik archiwum","color":"8b75a3","flag":"talked_lumen_reader","first":"Ruiny Lumen opisują rezonans jak język. Status jest słowem, kombinacja — zdaniem.","again":"Najsilniejsze reakcje nie muszą zadawać najwięcej obrażeń. Kontrola rundy też jest przewagą."},
	{"id":"lumen_curator","zone":"lumen","tile":[10,15],"name":"Rin","role":"kuratorka","color":"a68b68","flag":"talked_lumen_curator","first":"Za Lumen zaczyna się Las Aster. To pierwszy obszar, gdzie długa walka i regeneracja są częścią eksploracji.","again":"Przygotuj drużynę przed wejściem do Aster, nie dopiero po pierwszej porażce."},
	{"id":"aster_herbalist","zone":"aster","tile":[4,11],"name":"Eli","role":"zielarka","color":"5f9566","flag":"talked_aster_herbalist","first":"Aster nie jest spokojnym lasem. Pole reaguje tu na ruch, zakorzenienie i regenerację.","again":"Niektóre Somaskany mają dwie sensowne drogi budowy. Zmieniaj aktywne ruchy przed ważną próbą."},
	{"id":"aster_ranger","zone":"aster","tile":[10,15],"name":"Tor","role":"leśny zwiadowca","color":"587b63","flag":"talked_aster_ranger","first":"Cicha Niecka za miastem tłumi impulsy. Tam zaczyna się droga do zachodniego wybrzeża.","again":"W Niecce Focus i umiejętności trenera są równie ważne jak ruch partnera."},
	{"id":"koral_cartographer","zone":"koral","tile":[4,11],"name":"Nami","role":"kartografka raf","color":"4f91a1","flag":"talked_koral_cartographer","first":"Rafa jest boczną próbą przed Zenith, ale bez jej ukończenia północna droga nie uzna twojego rezonansu.","again":"Sprawdź skład przed Rafą. To najdłuższa morska seria starć w głównej kampanii."},
	{"id":"koral_divemaster","zone":"koral","tile":[10,15],"name":"Dey","role":"mistrz nurków","color":"557e9e","flag":"talked_koral_divemaster","first":"Po finale otworzy się Zewnętrzna Rafa. To nie część obowiązkowej drogi, tylko początek post-game.","again":"Rzadkie formy nie muszą być mocniejsze. Mają dawać inne rozwiązania."},
	{"id":"zenith_historian","zone":"zenith","tile":[4,11],"name":"Ilya","role":"historyczka","color":"8a7aa5","flag":"talked_zenith_historian","first":"Zenith nie jest ligą ani salą mistrzów. To miejsce, gdzie źródło regionalnego rezonansu wymusza ostatnią decyzję fabuły.","again":"Finał używa pełnego pojedynku trenerów. Sprzęt, Focus i gadżety mają znaczenie."},
	{"id":"zenith_technician","zone":"zenith","tile":[10,15],"name":"Oren","role":"technik rdzenia","color":"9c7959","flag":"talked_zenith_technician","first":"Po ustabilizowaniu rdzenia trzy obszary badawcze pozostaną otwarte. Kampania się kończy, kolekcjonowanie nie.","again":"Głębie Echa, Laboratorium Rezonansu i Zewnętrzna Rafa to pierwsza warstwa post-game."},
	{"id":"depths_researcher","zone":"echo_depths","tile":[5,11],"name":"Kae","role":"badacz głębi","color":"6c6295","flag":"talked_depths_researcher","first":"Tutaj poziomy przestają być główną miarą. Testujemy buildy przeciw rzadkim formom i długim kombinacjom.","again":"To obszar post-game — wracaj z innymi zestawami ruchów."},
	{"id":"lab_director","zone":"resonance_lab","tile":[5,11],"name":"Dr. Sen","role":"kierownik laboratorium","color":"5f86a0","flag":"talked_lab_director","first":"Laboratorium zbiera dane z całego regionu. Docelowo stąd ruszą zadania badawcze i kolejne regiony.","again":"Architektura SOMADEX nie kończy się na 50 rodzinach."},
	{"id":"shelf_keeper","zone":"outer_shelf","tile":[5,11],"name":"Ara","role":"opiekunka rafy","color":"4d8a94","flag":"talked_shelf_keeper","first":"Zewnętrzna Rafa jest otwarta dopiero po kampanii. Najrzadsze spotkania powinny wymagać eksploracji, nie sklepu.","again":"Szukaj różnych warunków pola i wracaj z innym buildem Badacza."}
]

static func in_zone(zone_id: String) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for spec: Dictionary in TRAINERS.specs():
		if str(spec.get("zone", "")) == zone_id:
			result.append(_trainer_npc(spec))
	for npc: Dictionary in _STORY_NPCS:
		if str(npc.get("zone", "")) == zone_id:
			var copy: Dictionary = npc.duplicate(true)
			copy["campaign"] = true
			result.append(copy)
	return result

static func at(zone_id: String, tile: Vector2i) -> Dictionary:
	for npc: Dictionary in in_zone(zone_id):
		if tile_of(npc) == tile:
			return npc
	return {}

static func tile_of(npc: Dictionary) -> Vector2i:
	var raw_tile: Array = npc.get("tile", []) as Array
	if raw_tile.size() >= 2:
		return Vector2i(int(raw_tile[0]), int(raw_tile[1]))
	return Vector2i(-1, -1)

static func dialogue(npc: Dictionary, flags: Dictionary) -> String:
	var npc_id: String = str(npc.get("id", ""))
	if bool(npc.get("trainer", false)) and TRAINERS.is_defeated(npc_id, flags):
		return "%s: %s" % [str(npc.get("name", "Trener")), str(npc.get("after", "Dobra walka. Droga jest otwarta."))]
	var flag_id: String = str(npc.get("flag", ""))
	if not flag_id.is_empty() and bool(flags.get(flag_id, false)):
		return "%s: %s" % [str(npc.get("name", "NPC")), str(npc.get("again", "..."))]
	return "%s: %s" % [str(npc.get("name", "NPC")), str(npc.get("first", "..."))]

static func _trainer_npc(spec: Dictionary) -> Dictionary:
	var id: String = str(spec.get("id", "trainer"))
	var boss: bool = bool(spec.get("boss", false))
	return {
		"id":id,"zone":str(spec.get("zone", "")),"tile":(spec.get("tile", []) as Array).duplicate(),
		"name":str(spec.get("name", "Trener")),"role":str(spec.get("title", "trener")),"color":"b36d55" if boss else "657aa4",
		"flag":"met_%s" % id,"trainer":true,"campaign":true,
		"first":"%s. Porozmawiaj ze mną ponownie, gdy chcesz rozpocząć pojedynek." % str(spec.get("title", "Sprawdzę twój rezonans")),
		"again":"Gotowy? Zaczynamy.","after":"Próba zakończona. Twój rezonans został zapisany."
	}

static func count() -> int:
	return _STORY_NPCS.size() + TRAINERS.trainer_count()

static func trainer_ids() -> Array[String]:
	return TRAINERS.ids()
