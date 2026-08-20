extends SceneTree

const CATALOG = preload("res://scripts/data/creature_catalog.gd")
const EVOLUTION = preload("res://scripts/data/evolution_db.gd")
const DB = preload("res://scripts/data/monster_db.gd")
const STATE = preload("res://scripts/core/game_state.gd")
const RULES = preload("res://scripts/battle/battle_rules.gd")

func _initialize() -> void:
	var errors: Array[String] = []
	_test_catalog_runtime(errors)
	_test_evolution_rules(errors)
	_test_party_evolution(errors)
	if errors.is_empty():
		print("EVOLUTION_RUNTIME_SMOKE: PASS")
		quit(0)
		return
	for error_text: String in errors:
		printerr("EVOLUTION_RUNTIME_SMOKE: " + error_text)
	quit(1)

func _test_catalog_runtime(errors: Array[String]) -> void:
	_expect(CATALOG.family_count() == 50, "catalog lost one or more families", errors)
	_expect(CATALOG.form_count() == 150, "catalog lost one or more forms", errors)
	var names: Array[String] = DB.all_names()
	_expect(names.size() == 150, "runtime database must expose all 150 catalog forms", errors)
	for creature_name: String in names:
		var data: Dictionary = DB.get_monster(creature_name)
		_expect(str(data.get("name", "")) == creature_name, creature_name + " resolves to the wrong runtime record", errors)
		_expect(int(data.get("max_hp", 0)) > 0, creature_name + " has invalid HP", errors)
		_expect(int(data.get("attack", 0)) > 0, creature_name + " has invalid attack", errors)
		_expect(int(data.get("defense", 0)) > 0, creature_name + " has invalid defense", errors)
		_expect((data.get("moves", []) as Array).size() == 4, creature_name + " does not expose four moves", errors)
	var generic: Dictionary = DB.get_monster("Mantrik")
	_expect(str(generic.get("name", "")) == "Mantrik", "family 50 base form is not runtime-capable", errors)

func _test_evolution_rules(errors: Array[String]) -> void:
	_expect(EVOLUTION.canonical_name("uczek") == "Uczek", "Uczek catalog alias is not canonicalized", errors)
	_expect(EVOLUTION.next_form("Luzik") == "Warstwin", "Luzik first evolution is broken", errors)
	_expect(EVOLUTION.next_form("Warstwin") == "Synkronaut", "Luzik final evolution is broken", errors)
	_expect(EVOLUTION.evolution_level("Luzik") == 12, "first evolution level must be 12", errors)
	_expect(EVOLUTION.evolution_level("Warstwin") == 28, "final evolution level must be 28", errors)
	_expect(EVOLUTION.resolve_name("Luzik", 11) == "Luzik", "Luzik evolves before level 12", errors)
	_expect(EVOLUTION.resolve_name("Luzik", 12) == "Warstwin", "Luzik does not evolve at level 12", errors)
	_expect(EVOLUTION.resolve_name("Luzik", 28) == "Synkronaut", "Luzik does not reach final form at level 28", errors)
	var base: Dictionary = DB.get_monster("Luzik")
	var stage2: Dictionary = DB.get_monster("Warstwin")
	var stage3: Dictionary = DB.get_monster("Synkronaut")
	_expect(int(stage2.get("max_hp", 0)) > int(base.get("max_hp", 0)), "stage 2 does not improve base stats", errors)
	_expect(int(stage3.get("max_hp", 0)) > int(stage2.get("max_hp", 0)), "final form does not improve stage 2 stats", errors)

func _test_party_evolution(errors: Array[String]) -> void:
	var profile: Dictionary = STATE.new_profile("Luzik")
	var party: Array = profile.get("party", []) as Array
	var member: Dictionary = party[0] as Dictionary
	member["level"] = 11
	member["xp"] = 0
	member["hp"] = STATE.base_member_max_hp(member)
	party[0] = member
	profile["party"] = party
	var gained: int = STATE.add_member_exp(profile, 0, RULES.creature_xp_to_next(11))
	_expect(gained == 1, "level 11 member did not gain exactly one level", errors)
	_expect(STATE.active_name(profile) == "Warstwin", "party member did not evolve into Warstwin", errors)
	_expect((profile.get("seen", []) as Array).has("Warstwin"), "evolved form was not added to seen registry", errors)
	_expect((profile.get("caught", []) as Array).has("Warstwin"), "evolved form was not added to caught registry", errors)
	var events: Array = profile.get("last_evolutions", []) as Array
	_expect(events.size() == 1, "evolution event was not recorded", errors)
	if not events.is_empty():
		var event: Dictionary = events[0] as Dictionary
		_expect(str(event.get("from", "")) == "Luzik" and str(event.get("to", "")) == "Warstwin", "evolution event contains wrong forms", errors)

	party = profile.get("party", []) as Array
	member = party[0] as Dictionary
	member["level"] = 27
	member["xp"] = 0
	party[0] = member
	profile["party"] = party
	STATE.add_member_exp(profile, 0, RULES.creature_xp_to_next(27))
	_expect(STATE.active_name(profile) == "Synkronaut", "stage 2 member did not reach final form", errors)

func _expect(condition: bool, message: String, errors: Array[String]) -> void:
	if not condition:
		errors.append(message)
