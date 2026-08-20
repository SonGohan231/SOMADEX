extends RefCounted

const REQUIRED_FIELDS: Array[String] = ["id","name","kind","move_type","power","accuracy","cost","priority","status","status_chance","animation","pattern","tags"]

static var _MOVES: Dictionary = {
	"layer_pulse": _m("layer_pulse", "Impuls Warstwowy", "attack", "REZONANS", 7, 0.96, 1, 0, "unstable", 0.35, "pulse", "direct", ["combo","resonance"]),
	"micro_slide": _m("micro_slide", "Mikroślizg", "attack", "PHYSICAL", 5, 1.00, 1, 1, "armor_break", 0.20, "dash", "direct", ["precision"]),
	"phase_shield": _m("phase_shield", "Osłona Fazowa", "guard", "SUPPORT", 0, 1.00, 1, 1, "guard", 1.00, "shield", "guard", ["defense"]),
	"synchronization": _m("synchronization", "Synchronizacja", "heal", "SUPPORT", 6, 1.00, 1, 0, "stabilny", 1.00, "heal", "heal", ["cleanse"]),
	"tangent_cut": _m("tangent_cut", "Cięcie Styczne", "attack", "PHYSICAL", 9, 0.88, 1, 0, "armor_break", 0.35, "slash", "direct", ["break"]),
	"side_step": _m("side_step", "Boczny Skok", "attack", "PHYSICAL", 6, 0.96, 1, 1, "stagger", 0.25, "dash", "direct", ["priority"]),
	"counter_cut": _m("counter_cut", "Kontra Ścinająca", "guard", "SUPPORT", 0, 1.00, 1, 2, "guard", 1.00, "counter", "counter", ["counter"]),
	"micro_cut": _m("micro_cut", "Mikrocięcie", "attack", "PHYSICAL", 5, 1.00, 1, 2, "bleed", 0.30, "slash", "multi", ["bleed","multi"]),
	"tiny_step": _m("tiny_step", "Znikomy Krok", "attack", "PHYSICAL", 6, 0.97, 1, 1, "stagger", 0.25, "dash", "direct", ["speed"]),
	"soft_return": _m("soft_return", "Miękki Powrót", "heal", "SUPPORT", 7, 1.00, 1, 0, "regen", 1.00, "heal", "heal", ["regen"]),
	"press": _m("press", "Docisk", "attack", "PHYSICAL", 7, 0.94, 1, 0, "rooted", 0.30, "impact", "direct", ["root"]),
	"unload": _m("unload", "Odciążenie", "attack", "REZONANS", 6, 0.95, 1, 0, "unstable", 0.25, "pulse", "conditional", ["combo"]),
	"osc_hit": _m("osc_hit", "Oscylo-Cios", "attack", "OSC", 6, 0.94, 1, 0, "unstable", 0.20, "osc", "multi", ["osc"]),
	"swing": _m("swing", "Wahnięcie", "attack", "OSC", 5, 0.98, 1, 1, "stagger", 0.20, "osc", "direct", ["tempo"]),
	"vibration": _m("vibration", "Drżenie", "attack", "REZONANS", 7, 0.84, 1, 0, "unstable", 0.45, "pulse", "prepared", ["setup"]),
	"vector": _m("vector", "Wektor", "attack", "REZONANS", 7, 0.96, 1, 0, "marked", 0.35, "vector", "direct", ["mark"]),
	"north_turn": _m("north_turn", "Zwrot Północny", "attack", "PHYSICAL", 6, 0.98, 1, 1, "stagger", 0.20, "dash", "direct", ["priority"]),
	"calibration": _m("calibration", "Kalibracja", "heal", "SUPPORT", 5, 1.00, 1, 0, "focused", 1.00, "heal", "setup", ["focus"]),
	"twist": _m("twist", "Skręt", "attack", "TORSJA", 8, 0.92, 1, 0, "armor_break", 0.40, "torsion", "direct", ["break"]),
	"thread": _m("thread", "Gwint", "attack", "REZONANS", 7, 0.94, 1, 0, "unstable", 0.30, "torsion", "multi", ["combo"]),
	"bypass": _m("bypass", "Obejście", "attack", "PHYSICAL", 7, 0.98, 1, 1, "armor_break", 0.25, "dash", "conditional", ["bypass"]),
	"field_arc": _m("field_arc", "Łuk Pola", "attack", "REZONANS", 6, 0.96, 1, 1, "disrupted", 0.35, "arc", "control", ["disrupt"]),
	"anchor": _m("anchor", "Kotwa", "attack", "STABIL", 6, 0.95, 1, 0, "rooted", 0.50, "anchor", "control", ["root"]),
	"point_weight": _m("point_weight", "Ciężar Punktu", "attack", "PHYSICAL", 8, 0.88, 1, 0, "stagger", 0.35, "impact", "direct", ["stagger"]),
	"stabilize": _m("stabilize", "Stabilizacja", "heal", "SUPPORT", 7, 1.00, 1, 0, "stabilny", 1.00, "heal", "heal", ["cleanse"]),
	"listen": _m("listen", "Nasłuch", "attack", "CZUCIE", 6, 0.99, 1, 1, "marked", 0.45, "sensor", "control", ["mark"]),
	"sensor_echo": _m("sensor_echo", "Echo Czujnika", "attack", "REZONANS", 7, 0.94, 1, 0, "charged", 0.35, "sensor", "conditional", ["charge"]),
	"resonance_tone": _m("resonance_tone", "Ton Rezonansu", "attack", "WAVE", 8, 0.92, 1, 0, "soaked", 0.35, "wave", "direct", ["soak"]),
	"mantra_echo": _m("mantra_echo", "Echo Mantry", "attack", "REZONANS", 7, 0.96, 1, 0, "charged", 0.25, "wave", "setup", ["charge"]),
	"interphase_silence": _m("interphase_silence", "Cisza Międzyfazowa", "guard", "SUPPORT", 0, 1.00, 1, 1, "silence", 1.00, "silence", "guard", ["control"]),
	"conductive_surge": _m("conductive_surge", "Przewodzący Skok", "attack", "ELECTRIC", 9, 0.90, 2, 0, "paralyzed", 0.30, "electric", "conditional", ["soaked_combo"]),
	"thermal_lock": _m("thermal_lock", "Termiczna Blokada", "attack", "ICE", 8, 0.92, 2, 0, "chilled", 0.45, "ice", "control", ["freeze_setup"]),
	"deep_freeze": _m("deep_freeze", "Głębokie Zamrożenie", "attack", "ICE", 11, 0.80, 2, -1, "frozen", 0.45, "ice", "prepared", ["finisher"]),
	"resin_coat": _m("resin_coat", "Powłoka Żywiczna", "guard", "SUPPORT", 0, 1.00, 1, 1, "oiled", 1.00, "resin", "setup", ["trap"]),
	"spark_ignition": _m("spark_ignition", "Zapłon Iskrowy", "attack", "FIRE", 10, 0.90, 2, 0, "burn", 0.45, "fire", "conditional", ["oiled_combo"]),
	"fracture_wave": _m("fracture_wave", "Fala Przełamania", "attack", "WAVE", 9, 0.90, 2, 0, "vulnerable", 0.30, "wave", "control", ["vulnerable"]),
	"resonance_burst": _m("resonance_burst", "Wybuch Rezonansu", "attack", "REZONANS", 12, 0.82, 2, -1, "unstable", 0.55, "burst", "prepared", ["finisher"]),
	"echo_chain": _m("echo_chain", "Łańcuch Echa", "attack", "WAVE", 4, 0.96, 2, 0, "charged", 0.20, "wave", "multi", ["multi"]),
	"spiral_series": _m("spiral_series", "Seria Spiralna", "attack", "TORSJA", 4, 0.95, 2, 0, "armor_break", 0.18, "torsion", "multi", ["multi"]),
	"static_net": _m("static_net", "Sieć Statyczna", "attack", "ELECTRIC", 5, 0.95, 2, 0, "paralyzed", 0.55, "electric", "control", ["control"]),
	"confusion_field": _m("confusion_field", "Pole Dezorientacji", "attack", "REZONANS", 3, 0.96, 2, 0, "confused", 0.50, "pulse", "control", ["control"]),
	"weakness_scan": _m("weakness_scan", "Skan Podatności", "attack", "CZUCIE", 2, 1.00, 1, 2, "vulnerable", 0.70, "sensor", "control", ["mark"]),
	"reactive_barrier": _m("reactive_barrier", "Bariera Reaktywna", "guard", "SUPPORT", 0, 1.00, 2, 3, "guard", 1.00, "shield", "counter", ["counter"]),
	"emergency_regen": _m("emergency_regen", "Regeneracja Awaryjna", "heal", "SUPPORT", 10, 1.00, 2, -1, "regen", 1.00, "heal", "heal", ["regen"]),
	"focused_breath": _m("focused_breath", "Skupiony Oddech", "heal", "SUPPORT", 4, 1.00, 1, 2, "focused", 1.00, "heal", "setup", ["focus"]),
	"root_breaker": _m("root_breaker", "Łamacz Korzeni", "attack", "PHYSICAL", 10, 0.90, 2, 0, "stagger", 0.35, "impact", "conditional", ["rooted_combo"]),
	"phase_counter": _m("phase_counter", "Kontra Fazowa", "guard", "SUPPORT", 0, 1.00, 2, 3, "guard", 1.00, "counter", "counter", ["counter","resonance"]),
	"final_harmonic": _m("final_harmonic", "Harmoniczny Finał", "attack", "REZONANS", 14, 0.78, 3, -2, "unstable", 0.60, "burst", "prepared", ["special","finisher"])
}

static func _m(id: String, name: String, kind: String, move_type: String, power: int, accuracy: float, cost: int, priority: int, status: String, status_chance: float, animation: String, pattern: String, tags: Array) -> Dictionary:
	return {"id":id,"name":name,"kind":kind,"move_type":move_type,"power":power,"accuracy":accuracy,"cost":cost,"priority":priority,"status":status,"status_chance":status_chance,"animation":animation,"pattern":pattern,"tags":tags.duplicate(),"extra_effect":{}}

static func ids() -> Array[String]:
	var result: Array[String] = []
	for key: Variant in _MOVES.keys():
		result.append(str(key))
	result.sort()
	return result

static func count() -> int:
	return _MOVES.size()

static func has(move_id: String) -> bool:
	return _MOVES.has(move_id)

static func info(move_id: String) -> Dictionary:
	if not _MOVES.has(move_id):
		return {}
	return (_MOVES[move_id] as Dictionary).duplicate(true)

static func normalize(raw: Dictionary) -> Dictionary:
	var result: Dictionary = raw.duplicate(true)
	var raw_id: String = str(result.get("id", ""))
	if raw_id.is_empty():
		raw_id = _slug(str(result.get("name", "move")))
	result["id"] = raw_id
	result["name"] = str(result.get("name", raw_id))
	result["kind"] = str(result.get("kind", "attack"))
	result["move_type"] = str(result.get("move_type", "PHYSICAL"))
	result["power"] = maxi(0, int(result.get("power", 0)))
	result["accuracy"] = clampf(float(result.get("accuracy", 1.0)), 0.0, 1.0)
	result["cost"] = maxi(0, int(result.get("cost", 1)))
	result["priority"] = int(result.get("priority", 0))
	result["status"] = str(result.get("status", ""))
	result["status_chance"] = clampf(float(result.get("status_chance", 0.0)), 0.0, 1.0)
	result["animation"] = str(result.get("animation", _default_animation(str(result["move_type"]), str(result["kind"]))))
	result["pattern"] = str(result.get("pattern", "direct"))
	var tags: Array = result.get("tags", []) as Array
	result["tags"] = tags.duplicate()
	if not result.has("extra_effect") or typeof(result["extra_effect"]) != TYPE_DICTIONARY:
		result["extra_effect"] = {}
	return result

static func validate(move_data: Dictionary) -> bool:
	for field: String in REQUIRED_FIELDS:
		if not move_data.has(field):
			return false
	var kind: String = str(move_data.get("kind", ""))
	return kind in ["attack", "heal", "guard"]

static func library_for_type(move_type: String) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for move_id: String in ids():
		var data: Dictionary = info(move_id)
		if str(data.get("move_type", "")) == move_type:
			result.append(data)
	return result

static func _default_animation(move_type: String, kind: String) -> String:
	if kind != "attack":
		return "support"
	match move_type:
		"PHYSICAL": return "impact"
		"WAVE", "FALA": return "wave"
		"TORSJA": return "torsion"
		"KIERUNEK": return "vector"
		"CZUCIE": return "sensor"
		"ELECTRIC": return "electric"
		"ICE": return "ice"
		"FIRE": return "fire"
		_: return "pulse"

static func _slug(text: String) -> String:
	var lowered: String = text.to_lower()
	var result: String = ""
	for i: int in range(lowered.length()):
		var code: int = lowered.unicode_at(i)
		if (code >= 97 and code <= 122) or (code >= 48 and code <= 57):
			result += lowered[i]
		elif result.is_empty() or not result.ends_with("_"):
			result += "_"
	return result.trim_suffix("_")
