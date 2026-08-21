extends RefCounted

const ORDER: Array[String] = [
	"orin_after_trial",
	"reed_first_field",
	"ferrum_line_after_marea",
	"ferrum_city_pressure",
	"nivra_pass_after_construct",
	"nivra_whiteout",
	"lumen_ruins_after_nivra",
	"lumen_memory_wakes",
	"aster_woods_after_lumen",
	"aster_crown_signal",
	"basin_after_aster",
	"koral_horizon",
	"zenith_approach_after_tide",
	"zenith_threshold",
	"zenith_after_final",
	"postgame_first_depth"
]

static var _BEATS: Dictionary = {
	"orin_after_trial":{"zone":"orin_gate","requires":["defeated_vela_trial"],"text":"Brama Orin odpowiada na zapis twojego rezonansu. Za Velą kończy się szkolenie — od tej chwili każdy biom wymusza inny sposób walki."},
	"reed_first_field":{"zone":"reed_marsh","requires":["defeated_vela_trial"],"text":"Mokradła tłumią zwykły rytm pola. Wilgoć wzmacnia część reakcji statusowych, ale wydłuża starcia i utrudnia szybkie zakończenia."},
	"ferrum_line_after_marea":{"zone":"ferrum_line","requires":["defeated_marea_resonance"],"text":"Sygnał Sory został zapisany w SOMADEX. Linia Ferrum otwiera się, a echo przypływu ustępuje rytmowi cewek i przeciążeń."},
	"ferrum_city_pressure":{"zone":"ferrum","requires":["defeated_marea_resonance"],"text":"Całe Ferrum pracuje ponad bezpieczny limit. Warsztaty jeszcze działają, ale źródło przeciążenia bije z Elektrowni Cewkowej."},
	"nivra_pass_after_construct":{"zone":"nivra_pass","requires":["defeated_ferrum_construct"],"text":"Po zatrzymaniu AX-7 pole regionu stabilizuje się tylko częściowo. Przełęcz Nivra odpowiada zimnym, długim impulsem prowadzącym ku górom."},
	"nivra_whiteout":{"zone":"nivra","requires":["defeated_ferrum_construct"],"text":"Nivra nie testuje samej siły. Długie walki, ograniczone zasoby i role w drużynie zaczynają ważyć więcej niż pojedynczy mocny ruch."},
	"lumen_ruins_after_nivra":{"zone":"lumen_ruins","requires":["defeated_nivra_guardian"],"text":"Głęboki Uskok zostaje za tobą. W Ruinach Lumen rezonans układa się w powtarzalne sekwencje — jakby pole przechowywało fragmenty języka."},
	"lumen_memory_wakes":{"zone":"lumen","requires":["defeated_nivra_guardian"],"text":"Archiwum Lumen reaguje na zapis twoich wcześniejszych starć. Kombinacje statusów zaczynają odsłaniać zależności, których nie widać po samych obrażeniach."},
	"aster_woods_after_lumen":{"zone":"aster_woods","requires":["defeated_lumen_keeper"],"text":"Po próbie Sol ścieżka do Aster rozświetla się zarodnikami. Regeneracja i kontrola tempa walki stają się częścią samej eksploracji."},
	"aster_crown_signal":{"zone":"aster","requires":["defeated_lumen_keeper"],"text":"Korony Aster przenoszą sygnał dalej niż ziemia. SOMADEX wykrywa, że część rzadkich form pojawia się tu tylko w krótkich oknach rezonansu."},
	"basin_after_aster":{"zone":"silent_basin","requires":["defeated_aster_warden"],"text":"Po pokonaniu Wardena Elow las nagle milknie. Cicha Niecka tłumi impulsy partnera, przez co Focus i działania trenera stają się znacznie ważniejsze."},
	"koral_horizon":{"zone":"koral","requires":["defeated_aster_warden"],"text":"Za Niecką wraca otwarte niebo i sól. Koral jest ostatnim dużym przystankiem przed Zenith, ale jego Rafa ma własną obowiązkową próbę."},
	"zenith_approach_after_tide":{"zone":"zenith_approach","requires":["defeated_koral_tide"],"text":"Próba Przypływu zamyka morski etap drogi. Podejście Zenith synchronizuje wszystkie dotychczasowe wzorce pola w jeden coraz silniejszy sygnał."},
	"zenith_threshold":{"zone":"zenith","requires":["defeated_koral_tide"],"text":"Rdzeń Zenith jest blisko. Ostatnia walka nie będzie pojedynkiem stworzeń — Veyr wymusi pełny pojedynek trenerów z wykorzystaniem Focus, sprzętu i gadżetów."},
	"zenith_after_final":{"zone":"zenith","requires":["defeated_zenith_final"],"text":"Rdzeń stabilizuje się. Główna kampania Regionu 1 jest zakończona, ale trzy odległe strefy badawcze przechodzą właśnie w tryb otwartej eksploracji."},
	"postgame_first_depth":{"zone":"echo_depths","requires":["defeated_zenith_final"],"text":"Głębie Echa nie są kolejnym rozdziałem fabuły, lecz laboratorium buildów i kolekcjonowania. Tutaj pełny katalog 150 form staje się częścią post-game."}
}

static func ids() -> Array[String]:
	return ORDER.duplicate()

static func count() -> int:
	return ORDER.size()

static func info(beat_id: String) -> Dictionary:
	if not _BEATS.has(beat_id):
		return {}
	return (_BEATS[beat_id] as Dictionary).duplicate(true)

static func flag_id(beat_id: String) -> String:
	return "story_beat_%s" % beat_id

static func next_for(zone_id: String, flags: Dictionary) -> Dictionary:
	for beat_id: String in ORDER:
		if bool(flags.get(flag_id(beat_id), false)):
			continue
		var beat: Dictionary = info(beat_id)
		if str(beat.get("zone", "")) != zone_id:
			continue
		var ready: bool = true
		for raw_flag: Variant in beat.get("requires", []) as Array:
			if not bool(flags.get(str(raw_flag), false)):
				ready = false
				break
		if ready:
			beat["id"] = beat_id
			beat["flag"] = flag_id(beat_id)
			return beat
	return {}
