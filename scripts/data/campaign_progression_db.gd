extends RefCounted

const ALPHA = preload("res://scripts/data/alpha1_quest_db.gd")

const STAGE_VELA_TRIAL: int = 10
const STAGE_MAREA: int = 11
const STAGE_FERRUM: int = 12
const STAGE_NIVRA: int = 13
const STAGE_LUMEN: int = 14
const STAGE_ASTER: int = 15
const STAGE_KORAL: int = 16
const STAGE_ZENITH: int = 17
const STAGE_POST_GAME: int = 18

const BOSS_ORDER: Array[String] = [
	"vela_trial",
	"marea_resonance",
	"ferrum_construct",
	"nivra_guardian",
	"lumen_keeper",
	"aster_warden",
	"koral_tide",
	"zenith_final"
]

static var _GATES: Dictionary = {
	"north_gate>orin_gate":"defeated_vela_trial",
	"marea>ferrum_line":"defeated_marea_resonance",
	"ferrum>nivra_pass":"defeated_ferrum_construct",
	"nivra>lumen_ruins":"defeated_nivra_guardian",
	"aster>silent_basin":"defeated_aster_warden",
	"koral>zenith_approach":"defeated_koral_tide",
	"zenith>echo_depths":"defeated_zenith_final",
	"ferrum>resonance_lab":"defeated_zenith_final",
	"koral>outer_shelf":"defeated_zenith_final"
}

static func defeated_flag(boss_id: String) -> String:
	return "defeated_%s" % boss_id

static func stage_for(dialogue_flags: Dictionary, current_stage: int) -> int:
	if current_stage < STAGE_VELA_TRIAL:
		return current_stage
	var stage: int = STAGE_VELA_TRIAL
	for index: int in range(BOSS_ORDER.size()):
		if not bool(dialogue_flags.get(defeated_flag(BOSS_ORDER[index]), false)):
			return stage
		stage = STAGE_VELA_TRIAL + index + 1
	return STAGE_POST_GAME

static func can_enter(from_zone: String, to_zone: String, dialogue_flags: Dictionary) -> bool:
	var key: String = "%s>%s" % [from_zone, to_zone]
	if not _GATES.has(key):
		return true
	return bool(dialogue_flags.get(str(_GATES[key]), false))

static func required_flag(from_zone: String, to_zone: String) -> String:
	return str(_GATES.get("%s>%s" % [from_zone, to_zone], ""))

static func lock_text(from_zone: String, to_zone: String) -> String:
	var flag_id: String = required_flag(from_zone, to_zone)
	match flag_id:
		"defeated_vela_trial": return "Brama Orin pozostaje zamknięta. Najpierw ukończ ostatnią próbę Veli."
		"defeated_marea_resonance": return "Linia Ferrum nie synchronizuje przejścia. Ukończ Rezonans Marei."
		"defeated_ferrum_construct": return "Przełęcz Nivra jest zablokowana przez przeciążenie. Pokonaj Konstrukt Ferrum."
		"defeated_nivra_guardian": return "Szlak do Lumen pozostaje niestabilny. Ukończ próbę Głębokiego Uskoku."
		"defeated_aster_warden": return "Cicha Niecka nie odpowiada. Strażnik Aster wciąż utrzymuje pole."
		"defeated_koral_tide": return "Podejście Zenith jest zamknięte. Najpierw ukończ Próbę Przypływu."
		"defeated_zenith_final": return "Ten obszar otwiera się dopiero po ustabilizowaniu rdzenia Zenith."
		_: return "Przejście jest jeszcze zablokowane przez progres kampanii."

static func short(stage: int) -> String:
	if stage < STAGE_VELA_TRIAL:
		return ALPHA.short(stage)
	match stage:
		STAGE_VELA_TRIAL: return "Ukończ ostatnią próbę Veli"
		STAGE_MAREA: return "Dotrzyj do Marei i pokonaj Sorę"
		STAGE_FERRUM: return "Zatrzymaj Konstrukt Ferrum"
		STAGE_NIVRA: return "Przejdź Nivrę i Głęboki Uskok"
		STAGE_LUMEN: return "Odkryj pamięć Lumen"
		STAGE_ASTER: return "Ukończ próbę Lasu Aster"
		STAGE_KORAL: return "Pokonaj Próbę Przypływu"
		STAGE_ZENITH: return "Wejdź do Zenith i ustabilizuj rdzeń"
		STAGE_POST_GAME: return "Post-game: trzy strefy badawcze"
		_: return "Kontynuuj kampanię regionu"

static func title(stage: int) -> String:
	if stage < STAGE_VELA_TRIAL:
		return ALPHA.title(stage)
	match stage:
		STAGE_VELA_TRIAL: return "PRÓBA VELI"
		STAGE_MAREA: return "REZONANS MAREI"
		STAGE_FERRUM: return "PRZECIĄŻENIE FERRUM"
		STAGE_NIVRA: return "STRAŻNIK NIVRY"
		STAGE_LUMEN: return "PAMIĘĆ LUMEN"
		STAGE_ASTER: return "KORONY ASTER"
		STAGE_KORAL: return "PRZYPŁYW KORAL"
		STAGE_ZENITH: return "RDZEŃ ZENITH"
		STAGE_POST_GAME: return "PO KAMPANII"
		_: return "REGION VELA"

static func objective(stage: int) -> String:
	if stage < STAGE_VELA_TRIAL:
		return ALPHA.objective(stage)
	match stage:
		STAGE_VELA_TRIAL: return "Pokonaj Strażnika Erona przy Północnej Bramie i otwórz drogę do Orin."
		STAGE_MAREA: return "Przejdź Brame Orin i Mokradła Stroików, a następnie pokonaj Mistrzynię Sorę w Marei."
		STAGE_FERRUM: return "Przejdź Linię Ferrum i zatrzymaj Konstrukt AX-7 w Elektrowni Cewkowej."
		STAGE_NIVRA: return "Przejdź Przełęcz Nivra i pokonaj Wardena Hail w Głębokim Uskoku."
		STAGE_LUMEN: return "Przeszukaj Ruiny Lumen i pokonaj Opiekuna Sol w archiwum miasta."
		STAGE_ASTER: return "Przejdź Las Aster i pokonaj Wardena Elow."
		STAGE_KORAL: return "Dotrzyj przez Cichą Nieckę do Koral i ukończ Próbę Przypływu na Rafie."
		STAGE_ZENITH: return "Przejdź Podejście Zenith i wygraj pełny pojedynek z Arcyrezonatorem Veyrem."
		STAGE_POST_GAME: return "Eksploruj Głębie Echa, Laboratorium Rezonansu i Zewnętrzną Rafę."
		_: return "Kontynuuj drogę przez region."

static func completed_boss_count(dialogue_flags: Dictionary) -> int:
	var count: int = 0
	for boss_id: String in BOSS_ORDER:
		if bool(dialogue_flags.get(defeated_flag(boss_id), false)):
			count += 1
	return count
