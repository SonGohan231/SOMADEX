extends RefCounted

const _EVENTS: Array[Dictionary] = [
	{"id":"orin_lens","zone":"orin_watchtower","tile":[5,7],"title":"Soczewka Orin","text":"Stara soczewka nadal śledzi drobne zaburzenia pola. Na horyzoncie widać kilka nakładających się ścieżek rezonansu.","requires":[]},
	{"id":"orin_signal","zone":"orin_watchtower","tile":[9,15],"title":"Zapis Strażnika","text":"W pamięci wieży został krótki zapis: granice regionu nie były budowane przeciw ludziom, tylko przeciw niestabilnym falom z głębi.","requires":["event_orin_lens"]},
	{"id":"reed_pool","zone":"reed_islet","tile":[5,7],"title":"Cichy Basen","text":"Woda jest niemal nieruchoma. Dopiero krok obok brzegu tworzy regularne koncentryczne odpowiedzi pola.","requires":[]},
	{"id":"reed_nest","zone":"reed_islet","tile":[9,15],"title":"Gniazdo Stroików","text":"Między łodygami widać ślady wielu różnych Somaskanów. Wyspa działa jak naturalny punkt odpoczynku dla rzadkich form.","requires":["event_reed_pool"]},
	{"id":"scrap_core","zone":"ferrum_scrapyard","tile":[5,7],"title":"Martwy Rdzeń","text":"Zużyty rdzeń AX nadal oddaje krótkie impulsy. Ferrum przez lata wyrzucało tu elementy, które zachowywały pamięć przeciążenia.","requires":[]},
	{"id":"scrap_pattern","zone":"ferrum_scrapyard","tile":[9,15],"title":"Wzór Przeciążenia","text":"Na blasze zapisano ręcznie sekwencję: obciążenie, przerwa, odprowadzenie. To prostszy poprzednik dzisiejszych cewek stabilizujących.","requires":["event_scrap_core"]},
	{"id":"nivra_scope","zone":"nivra_observatory","tile":[5,7],"title":"Lodowy Celownik","text":"Stary celownik nie pokazuje gwiazd. Reaguje za to na ruch w warstwach śniegu i na chwilę podświetla najstabilniejszą drogę.","requires":[]},
	{"id":"nivra_white_note","zone":"nivra_observatory","tile":[9,15],"title":"Notatka Białej Ciszy","text":"Ktoś opisał zjawisko, w którym hałas pola spada niemal do zera tuż przed gwałtownym pęknięciem rezonansu.","requires":["event_nivra_scope"]},
	{"id":"lumen_index","zone":"lumen_vault","tile":[5,7],"title":"Indeks Bez Tytułów","text":"Krypta zawiera indeks bez nazw. Każdy wpis jest tylko rytmem i kierunkiem, jakby pamięć regionu zapisywano ruchem zamiast słowami.","requires":[]},
	{"id":"lumen_echo_record","zone":"lumen_vault","tile":[9,15],"title":"Rekord Echa","text":"Po dotknięciu płyty wraca krótka sekwencja drgań. Układ przypomina sygnał wykrywany później w Aster i Zenith.","requires":["event_lumen_index"]},
	{"id":"aster_heartroot","zone":"aster_grove","tile":[5,7],"title":"Korzeń Serca","text":"Najstarszy korzeń gaju pulsuje bardzo wolno. Mniejsze korzenie dostosowują do niego własny rytm, zamiast z nim konkurować.","requires":[]},
	{"id":"aster_spore_ring","zone":"aster_grove","tile":[9,15],"title":"Krąg Zarodników","text":"Zarodniki układają się w pierścień, ale nie przekraczają jego środka. Naturalna bariera wygląda jak biologiczna wersja osłony fazowej.","requires":["event_aster_heartroot"]},
	{"id":"echo_first_voice","zone":"echo_sanctum","tile":[5,7],"title":"Pierwszy Głos","text":"Kryształy odtwarzają echo ruchu wykonanego chwilę wcześniej. Nie jest to nagranie dźwięku — reagują na zmianę całego pola.","requires":["defeated_zenith_final"]},
	{"id":"echo_deep_answer","zone":"echo_sanctum","tile":[9,15],"title":"Odpowiedź Głębi","text":"Po serii ech pojawia się odpowiedź, której nie wywołał gracz. Źródło znajduje się jeszcze głębiej niż obecna mapa regionu.","requires":["event_echo_first_voice"]},
	{"id":"annex_prototype","zone":"resonance_annex","tile":[5,7],"title":"Prototyp 4+1","text":"Terminal opisuje dawny eksperyment: cztery aktywne wzorce ruchu i jeden impuls specjalny uruchamiany przez trenera.","requires":["defeated_zenith_final"]},
	{"id":"annex_blackbox","zone":"resonance_annex","tile":[9,15],"title":"Czarna Skrzynka","text":"Ostatni wpis aneksu mówi o błędzie nie w urządzeniu, lecz w sposobie przewidywania zachowania żywego pola. To prowadzi poza Region 1.","requires":["event_annex_prototype"]},
	{"id":"trench_current","zone":"outer_trench","tile":[5,7],"title":"Prąd Głębinowy","text":"Prąd płynie przeciwnie do powierzchniowego przypływu Koral. Somaskany wykorzystują go jak niewidzialny szlak migracyjny.","requires":["defeated_zenith_final"]},
	{"id":"trench_beacon","zone":"outer_trench","tile":[9,15],"title":"Obcy Znacznik","text":"Na dnie tkwi znacznik wykonany w technologii niepasującej do Veli, Ferrum ani Lumen. Wskazuje kierunek poza granicę obecnego regionu.","requires":["event_trench_current"]}
]

static func ids() -> Array[String]:
	var result: Array[String] = []
	for event: Dictionary in _EVENTS:
		result.append(str(event.get("id", "")))
	return result

static func count() -> int:
	return _EVENTS.size()

static func info(event_id: String) -> Dictionary:
	for event: Dictionary in _EVENTS:
		if str(event.get("id", "")) == event_id:
			return event.duplicate(true)
	return {}

static func flag_id(event_id: String) -> String:
	return "event_%s" % event_id

static func tile_of(event: Dictionary) -> Vector2i:
	var raw: Variant = event.get("tile", [0,0])
	if typeof(raw) == TYPE_ARRAY and (raw as Array).size() >= 2:
		return Vector2i(int((raw as Array)[0]), int((raw as Array)[1]))
	return Vector2i.ZERO

static func is_complete(event_id: String, flags: Dictionary) -> bool:
	return bool(flags.get(flag_id(event_id), false))

static func requirements_met(event: Dictionary, flags: Dictionary) -> bool:
	for raw_flag: Variant in event.get("requires", []) as Array:
		if not bool(flags.get(str(raw_flag), false)):
			return false
	return true

static func at(zone_id: String, tile: Vector2i, flags: Dictionary) -> Dictionary:
	for event: Dictionary in _EVENTS:
		if str(event.get("zone", "")) != zone_id:
			continue
		if tile_of(event) != tile:
			continue
		var event_id: String = str(event.get("id", ""))
		if is_complete(event_id, flags) or not requirements_met(event, flags):
			continue
		return event.duplicate(true)
	return {}

static func in_zone(zone_id: String) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for event: Dictionary in _EVENTS:
		if str(event.get("zone", "")) == zone_id:
			result.append(event.duplicate(true))
	return result

static func completed_count(flags: Dictionary) -> int:
	var total: int = 0
	for event_id: String in ids():
		if is_complete(event_id, flags):
			total += 1
	return total
