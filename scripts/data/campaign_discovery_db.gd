extends RefCounted

const _DISCOVERIES: Array[Dictionary] = [
	{"id":"orin_gate_marks","zone_id":"orin_gate","tile":[3,4],"title":"ŚLADY NA MURZE","text":"Na kamieniu są trzy warstwy znaków. Najstarsze prowadzą w stronę Marei, nowsze ostrzegają przed zakłóceniami Ferrum."},
	{"id":"reed_marsh_echo","zone_id":"reed_marsh","tile":[3,3],"title":"ECHO STROIKÓW","text":"Wiatr układa trzcinę w powtarzalny rytm. Pole odpowiada tylko wtedy, gdy przestajesz się poruszać."},
	{"id":"marea_old_buoy","zone_id":"marea","tile":[10,4],"title":"STARA BOJA","text":"W metalu zapisano dawne częstotliwości przypływu. Jedna z nich nie odpowiada żadnemu współczesnemu pomiarowi."},
	{"id":"ferrum_line_spike","zone_id":"ferrum_line","tile":[11,3],"title":"PRZEPALONA SZPILA","text":"Przewodnik został stopiony od środka. To nie przeciążenie sieci — impuls przyszedł z gruntu."},
	{"id":"ferrum_workbench","zone_id":"ferrum","tile":[3,16],"title":"STÓŁ REZONATORA","text":"Na blacie leżą szkice urządzenia, które miało stroić pole bez udziału Somaskana. Projekt urywa się przed ostatnim etapem."},
	{"id":"coil_plant_hum","zone_id":"coil_plant","tile":[4,7],"title":"NISKI POMRUK","text":"Obudowa drży nawet po odcięciu zasilania. Cewki zachowują fragment rytmu konstruktu AX-7."},
	{"id":"nivra_pass_cairn","zone_id":"nivra_pass","tile":[3,15],"title":"KOPIEC SZLAKU","text":"Pod kamieniem ukryto znak starej ekspedycji. Kierunek nie prowadzi do miasta, tylko w stronę Głębokiego Uskoku."},
	{"id":"nivra_frost_note","zone_id":"nivra","tile":[11,4],"title":"NOTATKA W LODZIE","text":"Ktoś zamknął cienką płytkę pod warstwą lodu. Jest na niej tylko zdanie: „cisza przychodzi przed pęknięciem”."},
	{"id":"deep_fault_crystal","zone_id":"deep_fault","tile":[11,15],"title":"PĘKNIĘTY KRYSZTAŁ","text":"Kryształ odpowiada dwoma tonami jednocześnie. Jeden wraca z powierzchni, drugi z miejsca znacznie głębiej niż mapa uskoku."},
	{"id":"lumen_ruins_tablet","zone_id":"lumen_ruins","tile":[3,3],"title":"TABLICA LUMEN","text":"Wzór na tablicy nie opisuje stworzenia ani urządzenia. Wygląda jak mapa relacji między pamięcią, ruchem i rezonansem."},
	{"id":"lumen_archive_seal","zone_id":"lumen","tile":[10,16],"title":"PIECZĘĆ ARCHIWUM","text":"Pieczęć nosi ślady wielokrotnego otwierania. Ostatni zapis został wykonany już po oficjalnym zamknięciu archiwum."},
	{"id":"aster_woods_spores","zone_id":"aster_woods","tile":[4,7],"title":"ŚWIETLNY PYŁ","text":"Zarodniki układają się wokół dłoni, ale nie reagują na dotyk. Zmieniają kierunek dopiero przy zmianie napięcia pola."},
	{"id":"aster_crown_mark","zone_id":"aster","tile":[3,4],"title":"ZNAK KORONY","text":"Symbol na drewnie przedstawia pięć rozchodzących się dróg i jedną wspólną oś. Motyw przypomina ścieżki rozwoju trenera."},
	{"id":"silent_basin_ring","zone_id":"silent_basin","tile":[10,7],"title":"KRĄG CISZY","text":"Wewnątrz kręgu dźwięk nie znika — dociera z opóźnieniem. Pole zdaje się magazynować impuls zamiast go tłumić."},
	{"id":"koral_tide_map","zone_id":"koral","tile":[11,16],"title":"MAPA PRZYPŁYWU","text":"Stara mapa pokazuje dodatkową linię brzegu. Prowadzi dalej niż współczesna Rafa Koral, ku Zewnętrznej Rafie."},
	{"id":"koral_shelf_shell","zone_id":"koral_shelf","tile":[3,3],"title":"MUSZLA REZONANSOWA","text":"Muszla nie wzmacnia szumu morza. Wzmacnia ruch wody pod powierzchnią, jakby rejestrowała drugi przypływ."},
	{"id":"zenith_approach_pillar","zone_id":"zenith_approach","tile":[11,3],"title":"FILAR PODEJŚCIA","text":"Każda warstwa filaru ma inny wzór. Dopiero patrząc z boku widać, że wszystkie tworzą jeden ciąg prowadzący do rdzenia Zenith."},
	{"id":"zenith_core_scar","zone_id":"zenith","tile":[10,4],"title":"BLIZNA RDZENIA","text":"Ściana jest zeszklona od krótkiego, ogromnego impulsu. Ślad jest starszy niż obecna cytadela."},
	{"id":"echo_depths_signal","zone_id":"echo_depths","tile":[3,15],"title":"SYGNAŁ Z GŁĘBI","text":"Sygnał powtarza sekwencję o stałej długości. Nie przypomina naturalnego echa i nie pochodzi z żadnego znanego Somaskana."},
	{"id":"resonance_lab_log","zone_id":"resonance_lab","tile":[10,7],"title":"LOG BADAWCZY","text":"Najstarszy pomiar laboratorium zgadza się z danymi z Lumen i Zenith. Trzy odległe miejsca zarejestrowały ten sam impuls."},
	{"id":"outer_shelf_marker","zone_id":"outer_shelf","tile":[11,15],"title":"ZNACZNIK RAFY","text":"Metalowy znacznik skierowano ku otwartemu morzu. Na odwrocie wyryto numer kolejnej ekspedycji, która nigdy nie wróciła."}
]

static func ids() -> Array[String]:
	var result: Array[String] = []
	for discovery: Dictionary in _DISCOVERIES:
		result.append(str(discovery.get("id", "")))
	return result

static func count() -> int:
	return _DISCOVERIES.size()

static func info(discovery_id: String) -> Dictionary:
	for discovery: Dictionary in _DISCOVERIES:
		if str(discovery.get("id", "")) == discovery_id:
			return discovery.duplicate(true)
	return {}

static func flag_id(discovery_id: String) -> String:
	return "discovery_%s" % discovery_id

static func is_found(discovery_id: String, flags: Dictionary) -> bool:
	return bool(flags.get(flag_id(discovery_id), false))

static func tile_of(discovery: Dictionary) -> Vector2i:
	var raw: Array = discovery.get("tile", [0,0]) as Array
	if raw.size() < 2:
		return Vector2i.ZERO
	return Vector2i(int(raw[0]), int(raw[1]))

static func at(zone_id: String, tile: Vector2i, flags: Dictionary = {}) -> Dictionary:
	for discovery: Dictionary in _DISCOVERIES:
		if str(discovery.get("zone_id", "")) != zone_id:
			continue
		if tile_of(discovery) != tile:
			continue
		var discovery_id: String = str(discovery.get("id", ""))
		if is_found(discovery_id, flags):
			return {}
		return discovery.duplicate(true)
	return {}

static func found_count(flags: Dictionary) -> int:
	var total: int = 0
	for discovery_id: String in ids():
		if is_found(discovery_id, flags):
			total += 1
	return total
