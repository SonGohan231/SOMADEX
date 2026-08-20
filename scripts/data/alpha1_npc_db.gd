extends RefCounted

static var _NPCS: Array[Dictionary] = [
	{"id":"mira","zone":"vela","tile":[4,5],"name":"Mira","role":"przewodniczka","color":"925fb0","flag":"talked_mira","first":"Mira: Vela żyje z rezonansu. Najpierw poznaj obrzeża i Szlak, potem wróć do Stacji.","again":"Mira: Nie spiesz się. Dobra drużyna powstaje z obserwacji reakcji, nie tylko z siły."},
	{"id":"toma","zone":"vela","tile":[9,4],"name":"Toma","role":"technik","color":"4f8ea8","flag":"talked_toma","first":"Toma: Moduły są czułe na stan celu. Osłabienie i statusy ułatwiają synchronizację.","again":"Toma: Sprzęt trenera zmienia parametry całej drużyny."},
	{"id":"lina","zone":"vela","tile":[10,8],"name":"Lina","role":"mieszkanka","color":"c57a7a","flag":"talked_lina","first":"Lina: Na wschodzie Szlaku słychać morze. Szkliste Wybrzeże wygląda spokojnie, ale pole tam faluje.","again":"Lina: Jeśli pójdziesz na wybrzeże, sprawdź mosty przy odpływie."},
	{"id":"jaro","zone":"vela","tile":[5,18],"name":"Jaro","role":"kurier","color":"a87b45","flag":"talked_jaro","first":"Jaro: Obrzeża są najbezpieczniejszym miejscem na pierwsze łowy. Wyjście jest na zachodzie Veli.","again":"Jaro: Wysoka trawa na obrzeżach szybko zapełni pierwszy skład."},
	{"id":"nela","zone":"vela","tile":[9,19],"name":"Nela","role":"uczennica","color":"5aa070","flag":"talked_nela","first":"Nela: Chcę kiedyś zobaczyć Północną Bramę. Podobno przechodzą tylko trenerzy z prawdziwą więzią.","again":"Nela: Pokaż mi kiedyś sześciu Somaskanów naraz!"},

	{"id":"bor","zone":"vela_outskirts","tile":[7,4],"name":"Bor","role":"hodowca","color":"7f9252","flag":"talked_bor","first":"Bor: Dzikie pole zmienia się wraz z pogodą. Tutaj uczysz się czytać ruch trawy.","again":"Bor: Najpierw złap rytm kroków, potem rytm walki."},
	{"id":"sena","zone":"vela_outskirts","tile":[4,13],"name":"Sena","role":"zbieraczka","color":"b17f5b","flag":"talked_sena","first":"Sena: Zostawiam czasem Regeneratory przy kamieniach. W pełnej Veli pojawią się ukryte przedmioty.","again":"Sena: Zaglądaj poza główną ścieżkę."},

	{"id":"ivo","zone":"resonance_route","tile":[7,15],"name":"Ivo","role":"badacz","color":"596fb4","flag":"talked_route_scout","first":"Ivo: Szlak rozdziela się na trzy biomy. Las na północy, jaskinia na zachodzie, wybrzeże na wschodzie.","again":"Ivo: Różne biomy dostaną własne pule spotkań i reakcje pola."},
	{"id":"karo","zone":"resonance_route","tile":[5,14],"name":"Karo","role":"trener","color":"b45c51","flag":"met_karo","trainer":true,"first":"Karo: Kiedy wrócisz z pełną drużyną, sprawdzimy ją w prawdziwym pojedynku trenerskim.","again":"Karo: Przygotuj zmianę partnerów. W pojedynku jeden plan nie wystarczy."},
	{"id":"eni","zone":"resonance_route","tile":[11,17],"name":"Eni","role":"kartografka","color":"6fa7a0","flag":"talked_eni","first":"Eni: Zaznaczyłam wszystkie odnogi. Każda wraca na Szlak, więc nie zgubisz drogi do Veli.","again":"Eni: Północna Brama leży za Gajem Szeptów."},

	{"id":"syl","zone":"whispering_grove","tile":[7,9],"name":"Syl","role":"strażnik gaju","color":"477b55","flag":"talked_syl","first":"Syl: Gaj reaguje na hałas. Tu ruchy kontroli i stabilizacji są ważniejsze niż czysta siła.","again":"Syl: Północna ścieżka prowadzi do Bramy."},
	{"id":"vera","zone":"whispering_grove","tile":[5,17],"name":"Vera","role":"trenerka","color":"76589e","flag":"met_vera","trainer":true,"first":"Vera: Trener też walczy decyzjami. Zostaw sobie Focus na moment, który odwróci rundę.","again":"Vera: Spotkamy się jeszcze przed Bramą."},

	{"id":"maro","zone":"tideglass_coast","tile":[6,10],"name":"Maro","role":"rybak","color":"4d82a3","flag":"talked_maro","first":"Maro: Woda tutaj odbija sygnał jak szkło. Somaskany falowe czują się na wybrzeżu jak u siebie.","again":"Maro: Nie każda błyszcząca skała jest tylko skałą."},
	{"id":"tess","zone":"tideglass_coast","tile":[5,17],"name":"Tess","role":"technik terenowy","color":"a97651","flag":"talked_tess","first":"Tess: Mosty i mielizny będą otwierać skróty. Vela ma być miejscem, do którego warto wracać.","again":"Tess: Dobra mapa powinna dawać wybór, nie tylko korytarz."},

	{"id":"echo_keeper","zone":"echo_cave","tile":[7,15],"name":"Orin","role":"opiekun jaskini","color":"715b9d","flag":"talked_orin","first":"Orin: Kryształy zapamiętują drgania. W Jaskini Echa statusy mogą tworzyć bardzo mocne reakcje.","again":"Orin: Jeśli słyszysz dwa echa, drugie zwykle nie należy do ciebie."},

	{"id":"gate_guard","zone":"north_gate","tile":[7,12],"name":"Rhea","role":"strażniczka Bramy","color":"a65d54","flag":"talked_rhea","trainer":true,"first":"Rhea: To koniec pierwszego rozdziału Veli. Brama otworzy się po ukończeniu próby regionu.","again":"Rhea: Przygotuj drużynę, ekwipunek i komendy trenera. Próba sprawdzi wszystkie trzy."},
	{"id":"rival_kael","zone":"north_gate","tile":[7,8],"name":"Kael","role":"rywal","color":"4968a8","flag":"met_kael","trainer":true,"first":"Kael: Dotarłeś aż tutaj. Następnym razem nie będziemy tylko rozmawiać — sprawdzimy, czy twój rezonans działa pod presją.","again":"Kael: Wróć po treningu. Pojedynek przed Bramą ma mieć znaczenie."}
]

static func in_zone(zone_id: String) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for npc: Dictionary in _NPCS:
		if str(npc.get("zone", "")) == zone_id:
			result.append(npc.duplicate(true))
	return result

static func at(zone_id: String, tile: Vector2i) -> Dictionary:
	for npc: Dictionary in _NPCS:
		if str(npc.get("zone", "")) != zone_id:
			continue
		var raw_tile: Array = npc.get("tile", []) as Array
		if raw_tile.size() >= 2 and Vector2i(int(raw_tile[0]), int(raw_tile[1])) == tile:
			return npc.duplicate(true)
	return {}

static func tile_of(npc: Dictionary) -> Vector2i:
	var raw_tile: Array = npc.get("tile", []) as Array
	if raw_tile.size() >= 2:
		return Vector2i(int(raw_tile[0]), int(raw_tile[1]))
	return Vector2i(-1, -1)

static func dialogue(npc: Dictionary, flags: Dictionary) -> String:
	var flag_id: String = str(npc.get("flag", ""))
	if not flag_id.is_empty() and bool(flags.get(flag_id, false)):
		return "%s: %s" % [str(npc.get("name", "NPC")), str(npc.get("again", "..."))]
	return "%s: %s" % [str(npc.get("name", "NPC")), str(npc.get("first", "..."))]

static func count() -> int:
	return _NPCS.size()

static func trainer_ids() -> Array[String]:
	var result: Array[String] = []
	for npc: Dictionary in _NPCS:
		if bool(npc.get("trainer", false)):
			result.append(str(npc.get("id", "")))
	return result
