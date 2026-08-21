extends RefCounted

static var _GADGETS: Dictionary = {
	"phase_barrier": {"name":"Bariera Fazowa","effect":"guard","value":1,"focus":0,"status":"","description":"Rozstawia jednorundową osłonę dla aktywnego partnera."},
	"mist_projector": {"name":"Projektor Mgły","effect":"enemy_status","value":2,"focus":0,"status":"soaked","description":"Nakłada MOKRY i otwiera reakcje elektryczne oraz lodowe."},
	"overload_coil": {"name":"Cewka Przeciążenia","effect":"damage","value":10,"focus":1,"status":"charged","description":"Impuls bojowy zadający obrażenia i ładujący pole."},
	"grounding_spike": {"name":"Kotwa Uziemiająca","effect":"enemy_status","value":2,"focus":0,"status":"rooted","description":"Kotwiczy przeciwnika w polu i ogranicza jego mobilność."},
	"echo_mine": {"name":"Mina Echa","effect":"damage_status","value":7,"focus":0,"status":"unstable","description":"Fala zwrotna zadaje obrażenia i destabilizuje cel."},
	"emergency_shunt": {"name":"Bocznik Awaryjny","effect":"heal","value":12,"focus":0,"status":"","description":"Przekierowuje energię do aktywnego Somaskana."},
	"focus_capacitor": {"name":"Kondensator Focus","effect":"focus","value":2,"focus":0,"status":"","description":"Natychmiast odzyskuje Focus trenera."},
	"stability_anchor": {"name":"Kotwa Stabilności","effect":"stability","value":18,"focus":0,"status":"","description":"Odbudowuje koncentrację trenera w pojedynku rezonansowym."},
	"resin_capsule": {"name":"Kapsuła Żywicy","effect":"enemy_status","value":3,"focus":0,"status":"oiled","description":"Pokrywa cel żywicą, przygotowując reakcję ogniową."},
	"cryo_pulse": {"name":"Impuls Kriogeniczny","effect":"enemy_status","value":2,"focus":1,"status":"chilled","description":"Wychładza pole i przygotowuje zamrożenie."},
	"signal_jammer": {"name":"Zakłócacz Sygnału","effect":"enemy_status","value":2,"focus":1,"status":"disrupted","description":"Zakłóca odpowiedź przeciwnika i obniża jego presję."},
	"regen_beacon": {"name":"Znacznik Regeneracji","effect":"player_status","value":2,"focus":0,"status":"regen","description":"Nadaje partnerowi regenerację na kolejne rundy."}
}

static var _QUICK_ORDER: Array[String] = [
	"phase_barrier", "mist_projector", "overload_coil", "grounding_spike", "echo_mine", "emergency_shunt",
	"focus_capacitor", "stability_anchor", "resin_capsule", "cryo_pulse", "signal_jammer", "regen_beacon"
]

static func ids() -> Array[String]:
	var result: Array[String] = []
	for gadget_id: String in _QUICK_ORDER:
		result.append(gadget_id)
	return result

static func quick_ids(limit: int = 6) -> Array[String]:
	var result: Array[String] = []
	for gadget_id: String in _QUICK_ORDER:
		if result.size() >= limit:
			break
		result.append(gadget_id)
	return result

static func has(gadget_id: String) -> bool:
	return _GADGETS.has(gadget_id)

static func info(gadget_id: String) -> Dictionary:
	if not _GADGETS.has(gadget_id):
		return {}
	var result: Dictionary = (_GADGETS[gadget_id] as Dictionary).duplicate(true)
	result["id"] = gadget_id
	result["category"] = "gadget"
	return result

static func count() -> int:
	return _GADGETS.size()
