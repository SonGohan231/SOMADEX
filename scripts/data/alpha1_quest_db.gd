extends RefCounted

static func stage_for(world_flags: Dictionary, dialogue_flags: Dictionary, current_stage: int) -> int:
	if current_stage < 5 and not bool(world_flags.get("route_entered", false)):
		return current_stage
	if not bool(world_flags.get("route_entered", false)):
		return maxi(current_stage, 4)

	var stage: int = 5
	var explored: bool = (
		bool(world_flags.get("visited_whispering_grove", false))
		and bool(world_flags.get("visited_tideglass_coast", false))
		and bool(world_flags.get("visited_echo_cave", false))
	)
	if not explored:
		return stage

	stage = 6
	if not (bool(dialogue_flags.get("trainer_karo_defeated", false)) and bool(dialogue_flags.get("trainer_vera_defeated", false))):
		return stage

	stage = 7
	if not bool(world_flags.get("visited_north_gate", false)):
		return stage

	stage = 8
	if not bool(dialogue_flags.get("trainer_kael_defeated", false)):
		return stage

	stage = 9
	if not bool(dialogue_flags.get("trainer_rhea_defeated", false)):
		return stage
	return 10

static func title(stage: int) -> String:
	match stage:
		5: return "TRZY ECHA VELI"
		6: return "PRÓBY TRENERÓW"
		7: return "PÓŁNOCNA BRAMA"
		8: return "RYWAL: KAEL"
		9: return "PRÓBA RHEI"
		10: return "VELA: REZONANS OTWARTY"
		_: return ""

static func objective(stage: int) -> String:
	match stage:
		5: return "Odwiedź Gaj Szeptów, Szkliste Wybrzeże i Jaskinię Echa."
		6: return "Pokonaj Karo na Szlaku i Verę w Gaju Szeptów."
		7: return "Przejdź przez Gaj Szeptów do Północnej Bramy."
		8: return "Pokonaj Kaela w pojedynku rywali."
		9: return "Pokonaj Rheę i ukończ regionalną próbę Veli."
		10: return "Rozdział Vela ukończony. Północna Brama jest gotowa do dalszej części regionu."
		_: return ""

static func short(stage: int) -> String:
	match stage:
		5: return "Poznaj trzy biomy Veli"
		6: return "Pokonaj Karo i Verę"
		7: return "Dotrzyj do Północnej Bramy"
		8: return "Pokonaj Kaela"
		9: return "Ukończ próbę Rhei"
		10: return "Rozdział Vela ukończony"
		_: return ""
