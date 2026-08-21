extends RefCounted

static var _RECIPES: Dictionary = {
	"craft_phase_barrier": {"name":"Bariera Fazowa","inputs":{"alloy_scrap":2,"resonance_dust":1},"outputs":{"phase_barrier":1},"technician":0},
	"craft_mist_projector": {"name":"Projektor Mgły","inputs":{"glass_fiber":1,"resonance_dust":2},"outputs":{"mist_projector":1},"technician":0},
	"craft_overload_coil": {"name":"Cewka Przeciążenia","inputs":{"copper_coil":2,"charged_crystal":1},"outputs":{"overload_coil":1},"technician":2},
	"craft_grounding_spike": {"name":"Kotwa Uziemiająca","inputs":{"alloy_scrap":2,"copper_coil":1},"outputs":{"grounding_spike":1},"technician":1},
	"craft_echo_mine": {"name":"Mina Echa","inputs":{"echo_shard":2,"alloy_scrap":1},"outputs":{"echo_mine":1},"technician":3},
	"craft_emergency_shunt": {"name":"Bocznik Awaryjny","inputs":{"copper_coil":1,"bio_gel":2},"outputs":{"emergency_shunt":1},"technician":0},
	"craft_focus_capacitor": {"name":"Kondensator Focus","inputs":{"charged_crystal":1,"copper_coil":2},"outputs":{"focus_capacitor":1},"technician":4},
	"craft_stability_anchor": {"name":"Kotwa Stabilności","inputs":{"echo_shard":1,"alloy_scrap":2,"resonance_dust":1},"outputs":{"stability_anchor":1},"technician":5},
	"craft_resin_capsule": {"name":"Kapsuła Żywicy","inputs":{"resin_pod":2,"glass_fiber":1},"outputs":{"resin_capsule":1},"technician":0},
	"craft_cryo_pulse": {"name":"Impuls Kriogeniczny","inputs":{"cryo_salt":2,"charged_crystal":1},"outputs":{"cryo_pulse":1},"technician":4},
	"craft_signal_jammer": {"name":"Zakłócacz Sygnału","inputs":{"copper_coil":2,"echo_shard":1},"outputs":{"signal_jammer":1},"technician":6},
	"craft_regen_beacon": {"name":"Znacznik Regeneracji","inputs":{"bio_gel":2,"resonance_dust":1},"outputs":{"regen_beacon":1},"technician":1}
}

static var _ORDER: Array[String] = [
	"craft_phase_barrier", "craft_mist_projector", "craft_overload_coil", "craft_grounding_spike",
	"craft_echo_mine", "craft_emergency_shunt", "craft_focus_capacitor", "craft_stability_anchor",
	"craft_resin_capsule", "craft_cryo_pulse", "craft_signal_jammer", "craft_regen_beacon"
]

static func ids() -> Array[String]:
	var result: Array[String] = []
	for recipe_id: String in _ORDER:
		result.append(recipe_id)
	return result

static func info(recipe_id: String) -> Dictionary:
	if not _RECIPES.has(recipe_id):
		return {}
	var result: Dictionary = (_RECIPES[recipe_id] as Dictionary).duplicate(true)
	result["id"] = recipe_id
	return result

static func can_craft(inventory: Dictionary, recipe_id: String, technician_investment: int) -> bool:
	var recipe: Dictionary = info(recipe_id)
	if recipe.is_empty():
		return false
	if technician_investment < int(recipe.get("technician", 0)):
		return false
	var inputs: Dictionary = recipe.get("inputs", {}) as Dictionary
	for raw_id: Variant in inputs.keys():
		var item_id: String = str(raw_id)
		if int(inventory.get(item_id, 0)) < int(inputs.get(raw_id, 0)):
			return false
	return true

static func craft(inventory: Dictionary, recipe_id: String, technician_investment: int) -> Dictionary:
	if not can_craft(inventory, recipe_id, technician_investment):
		return {"crafted":false,"inventory":inventory.duplicate(true),"recipe":recipe_id}
	var updated: Dictionary = inventory.duplicate(true)
	var recipe: Dictionary = info(recipe_id)
	var inputs: Dictionary = recipe.get("inputs", {}) as Dictionary
	for raw_id: Variant in inputs.keys():
		var item_id: String = str(raw_id)
		updated[item_id] = maxi(0, int(updated.get(item_id, 0)) - int(inputs.get(raw_id, 0)))
	var outputs: Dictionary = recipe.get("outputs", {}) as Dictionary
	for raw_id: Variant in outputs.keys():
		var item_id: String = str(raw_id)
		updated[item_id] = maxi(0, int(updated.get(item_id, 0))) + int(outputs.get(raw_id, 0))
	return {"crafted":true,"inventory":updated,"recipe":recipe_id,"name":str(recipe.get("name", recipe_id))}

static func input_text(recipe_id: String) -> String:
	var recipe: Dictionary = info(recipe_id)
	var inputs: Dictionary = recipe.get("inputs", {}) as Dictionary
	var parts: Array[String] = []
	for raw_id: Variant in inputs.keys():
		parts.append("%s×%d" % [str(raw_id), int(inputs.get(raw_id, 0))])
	return "  ".join(parts)

static func count() -> int:
	return _RECIPES.size()
