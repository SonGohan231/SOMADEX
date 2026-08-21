extends RefCounted

# Optional Region 1 content beyond the three authored Vela sidequests.
# These quests deliberately reuse persistent dialogue/pickup/trainer flags so
# they survive saves without introducing a second quest-state system.

const ORDER: Array[String] = [
	"orin_border_records",
	"reed_wet_chain",
	"marea_tide_memory",
	"marea_field_tools",
	"ferrum_scrap_cycle",
	"ferrum_coil_map",
	"coil_shutdown_samples",
	"nivra_route_marks",
	"nivra_shelter_cache",
	"fault_echo_series",
	"lumen_lost_index",
	"lumen_combo_notes",
	"aster_spore_samples",
	"aster_crown_route",
	"basin_silent_marks",
	"koral_chart_fragments",
	"reef_tide_samples",
	"zenith_field_logs",
	"zenith_core_relay",
	"post_depths_echo",
	"research_triangle"
]

static var _QUESTS: Dictionary = {
	"orin_border_records": {
		"title":"ZAPISY GRANICY",
		"start_flag":"talked_orin_archivist",
		"requirements":["pickup_secret_orin_gate_a","pickup_secret_orin_gate_b"],
		"complete_flag":"sidequest_orin_border_records_complete",
		"reward":{"resonance_dust":3,"capture_modules":1},
		"description":"Odszukaj dwa stare znaczniki pola ukryte przy Bramie Orin."
	},
	"reed_wet_chain": {
		"title":"ŁAŃCUCH MOKRY",
		"start_flag":"talked_orin_medic",
		"requirements":["pickup_secret_reed_marsh_a","defeated_reed_scout_2"],
		"complete_flag":"sidequest_reed_wet_chain_complete",
		"reward":{"cryo_salt":2,"resonance_cells":1},
		"description":"Zbierz próbkę z mokradeł i sprawdź ją w starciu z badaczem Stroików."
	},
	"marea_tide_memory": {
		"title":"PAMIĘĆ PRZYPŁYWU",
		"start_flag":"talked_marea_sailor",
		"requirements":["pickup_secret_marea_a","pickup_secret_marea_b"],
		"complete_flag":"sidequest_marea_tide_memory_complete",
		"reward":{"glass_fiber":3,"sondas":1},
		"description":"Odnajdź dwa znaczniki dawnych przypływów w Marei."
	},
	"marea_field_tools": {
		"title":"NARZĘDZIA PORTOWE",
		"start_flag":"talked_marea_engineer",
		"requirements":["defeated_marea_duelist_2","pickup_region_marea_a"],
		"complete_flag":"sidequest_marea_field_tools_complete",
		"reward":{"copper_coil":3,"regenerators":2},
		"description":"Zdobądź materiał z nabrzeża i przetestuj go w pojedynku portowym."
	},
	"ferrum_scrap_cycle": {
		"title":"DRUGI OBIEG STOPU",
		"start_flag":"talked_ferrum_foreman",
		"requirements":["pickup_secret_ferrum_line_a","pickup_secret_ferrum_line_b"],
		"complete_flag":"sidequest_ferrum_scrap_cycle_complete",
		"reward":{"alloy_scrap":4,"grounding_spike":1},
		"description":"Zbierz odrzucone elementy ze starej Linii Ferrum."
	},
	"ferrum_coil_map": {
		"title":"MAPA CEWEK",
		"start_flag":"talked_ferrum_crafter",
		"requirements":["pickup_secret_ferrum_a","pickup_secret_ferrum_b"],
		"complete_flag":"sidequest_ferrum_coil_map_complete",
		"reward":{"copper_coil":4,"overload_coil":1},
		"description":"Odtwórz układ dwóch zapomnianych węzłów warsztatowych Ferrum."
	},
	"coil_shutdown_samples": {
		"title":"PRÓBKI PO WYŁĄCZENIU",
		"start_flag":"talked_ferrum_crafter",
		"requirements":["pickup_secret_coil_plant_a","defeated_coil_guard_2"],
		"complete_flag":"sidequest_coil_shutdown_samples_complete",
		"reward":{"charged_crystal":3,"focus_capacitor":1},
		"description":"Zbierz kryształ z Elektrowni i przejdź test pola operatora Miraxa."
	},
	"nivra_route_marks": {
		"title":"ZNACZNIKI GRANI",
		"start_flag":"talked_nivra_sage",
		"requirements":["pickup_secret_nivra_pass_a","pickup_secret_nivra_pass_b"],
		"complete_flag":"sidequest_nivra_route_marks_complete",
		"reward":{"cryo_salt":3,"stability_anchor":1},
		"description":"Odszukaj dwa zasypane znaczniki na Przełęczy Nivra."
	},
	"nivra_shelter_cache": {
		"title":"SKRYTKA SCHRONU",
		"start_flag":"talked_nivra_keeper",
		"requirements":["pickup_secret_nivra_a","pickup_secret_nivra_b"],
		"complete_flag":"sidequest_nivra_shelter_cache_complete",
		"reward":{"regenerators":3,"phase_barrier":1},
		"description":"Znajdź dwie awaryjne skrytki pozostawione wokół Nivry."
	},
	"fault_echo_series": {
		"title":"SERIA ECHA",
		"start_flag":"talked_nivra_sage",
		"requirements":["pickup_secret_deep_fault_a","pickup_secret_deep_fault_b"],
		"complete_flag":"sidequest_fault_echo_series_complete",
		"reward":{"echo_shard":4,"echo_mine":1},
		"description":"Zbierz dwie próbki z przeciwnych ścian Głębokiego Uskoku."
	},
	"lumen_lost_index": {
		"title":"UTRACONY INDEKS",
		"start_flag":"talked_lumen_reader",
		"requirements":["pickup_secret_lumen_ruins_a","pickup_secret_lumen_ruins_b"],
		"complete_flag":"sidequest_lumen_lost_index_complete",
		"reward":{"resonance_dust":4,"signal_jammer":1},
		"description":"Odnajdź dwa fragmenty indeksu rozrzucone w Ruinach Lumen."
	},
	"lumen_combo_notes": {
		"title":"ZDANIA REZONANSU",
		"start_flag":"talked_lumen_curator",
		"requirements":["pickup_secret_lumen_a","defeated_lumen_archivist_2"],
		"complete_flag":"sidequest_lumen_combo_notes_complete",
		"reward":{"resonance_cells":2,"focus_capacitor":1},
		"description":"Połącz notatkę archiwum z praktycznym testem strażnika Pax."
	},
	"aster_spore_samples": {
		"title":"ZARODNIKI ASTER",
		"start_flag":"talked_aster_herbalist",
		"requirements":["pickup_secret_aster_woods_a","pickup_secret_aster_woods_b"],
		"complete_flag":"sidequest_aster_spore_samples_complete",
		"reward":{"bio_gel":4,"regen_beacon":1},
		"description":"Zbierz dwie nietypowe próbki z głębi Lasu Aster."
	},
	"aster_crown_route": {
		"title":"SZLAK KORON",
		"start_flag":"talked_aster_ranger",
		"requirements":["pickup_secret_aster_a","pickup_secret_aster_b"],
		"complete_flag":"sidequest_aster_crown_route_complete",
		"reward":{"resin_pod":4,"mist_projector":1},
		"description":"Odszukaj dwa punkty dawnej ścieżki prowadzącej ponad koronami."
	},
	"basin_silent_marks": {
		"title":"ZNAKI CISZY",
		"start_flag":"talked_aster_ranger",
		"requirements":["pickup_secret_silent_basin_a","pickup_secret_silent_basin_b"],
		"complete_flag":"sidequest_basin_silent_marks_complete",
		"reward":{"echo_shard":3,"stability_anchor":1},
		"description":"Znajdź dwa znaczniki, których pole nie daje się wykryć z dystansu."
	},
	"koral_chart_fragments": {
		"title":"ROZERWANA MAPA RAF",
		"start_flag":"talked_koral_cartographer",
		"requirements":["pickup_secret_koral_a","pickup_secret_koral_b"],
		"complete_flag":"sidequest_koral_chart_fragments_complete",
		"reward":{"glass_fiber":4,"sondas":2},
		"description":"Złóż dwa brakujące fragmenty mapy prądów Koral."
	},
	"reef_tide_samples": {
		"title":"PRÓBKI PRZYPŁYWU",
		"start_flag":"talked_koral_divemaster",
		"requirements":["pickup_secret_koral_shelf_a","defeated_koral_shelf_2"],
		"complete_flag":"sidequest_reef_tide_samples_complete",
		"reward":{"charged_crystal":3,"cryo_pulse":1},
		"description":"Zbierz rzadką próbkę Rafy i przejdź kontrolny pojedynek Lune."
	},
	"zenith_field_logs": {
		"title":"DZIENNIKI PODEJŚCIA",
		"start_flag":"talked_zenith_historian",
		"requirements":["pickup_secret_zenith_approach_a","defeated_zenith_approach_3"],
		"complete_flag":"sidequest_zenith_field_logs_complete",
		"reward":{"resonance_dust":5,"phase_barrier":1},
		"description":"Odzyskaj zapis pola i przejdź ostatnią straż przed Zenith."
	},
	"zenith_core_relay": {
		"title":"PRZEKAŹNIK RDZENIA",
		"start_flag":"talked_zenith_technician",
		"requirements":["pickup_secret_zenith_a","defeated_zenith_core_duelist"],
		"complete_flag":"sidequest_zenith_core_relay_complete",
		"reward":{"charged_crystal":5,"focus_capacitor":2},
		"description":"Odnajdź ukryty przekaźnik i przejdź techniczny pojedynek rdzenia."
	},
	"post_depths_echo": {
		"title":"ECHO PO FINALE",
		"start_flag":"talked_depths_researcher",
		"requirements":["pickup_secret_echo_depths_a","pickup_region_echo_depths_a"],
		"complete_flag":"sidequest_post_depths_echo_complete",
		"reward":{"echo_shard":6,"regen_beacon":2},
		"description":"Porównaj ukrytą próbkę Głębi z materiałem z głównego stanowiska badawczego."
	},
	"research_triangle": {
		"title":"TRÓJKĄT BADAWCZY",
		"start_flag":"talked_lab_director",
		"requirements":["pickup_secret_resonance_lab_a","pickup_secret_outer_shelf_a","talked_shelf_keeper"],
		"complete_flag":"sidequest_research_triangle_complete",
		"reward":{"resonance_cells":3,"capture_modules":3,"sondas":3},
		"description":"Zbierz dane z Laboratorium i Zewnętrznej Rafy, a następnie porozmawiaj z Arą."
	}
}

static func ids() -> Array[String]:
	return ORDER.duplicate()

static func info(quest_id: String) -> Dictionary:
	if not _QUESTS.has(quest_id):
		return {}
	return (_QUESTS[quest_id] as Dictionary).duplicate(true)

static func is_started(quest_id: String, flags: Dictionary) -> bool:
	var data: Dictionary = info(quest_id)
	return not data.is_empty() and bool(flags.get(str(data.get("start_flag", "")), false))

static func is_complete(quest_id: String, flags: Dictionary) -> bool:
	var data: Dictionary = info(quest_id)
	return not data.is_empty() and bool(flags.get(str(data.get("complete_flag", "")), false))

static func can_complete(quest_id: String, flags: Dictionary) -> bool:
	if not is_started(quest_id, flags) or is_complete(quest_id, flags):
		return false
	var requirements: Array = info(quest_id).get("requirements", []) as Array
	for raw_flag: Variant in requirements:
		if not bool(flags.get(str(raw_flag), false)):
			return false
	return true

static func complete_flag(quest_id: String) -> String:
	return str(info(quest_id).get("complete_flag", "sidequest_%s_complete" % quest_id))

static func reward(quest_id: String) -> Dictionary:
	var raw: Variant = info(quest_id).get("reward", {})
	if typeof(raw) != TYPE_DICTIONARY:
		return {}
	return (raw as Dictionary).duplicate(true)

static func progress_text(quest_id: String, flags: Dictionary) -> String:
	var data: Dictionary = info(quest_id)
	if data.is_empty():
		return quest_id
	if is_complete(quest_id, flags):
		return "%s · UKOŃCZONE" % str(data.get("title", quest_id))
	if not is_started(quest_id, flags):
		return "%s · NIEODKRYTE" % str(data.get("title", quest_id))
	var requirements: Array = data.get("requirements", []) as Array
	var done: int = 0
	for raw_flag: Variant in requirements:
		if bool(flags.get(str(raw_flag), false)):
			done += 1
	return "%s · %d/%d" % [str(data.get("title", quest_id)), done, requirements.size()]
