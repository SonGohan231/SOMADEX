extends SceneTree

const STATE = preload("res://scripts/core/game_state.gd")
const PROGRESSION = preload("res://scripts/data/progression_db.gd")
const ITEMS = preload("res://scripts/data/item_db.gd")
const EQUIPMENT = preload("res://scripts/data/equipment_db.gd")
const GADGETS = preload("res://scripts/data/gadget_db.gd")
const CRAFTING = preload("res://scripts/data/crafting_db.gd")
const BATTLE = preload("res://scripts/battle/loadout_battle_screen.gd")
const MENU = preload("res://scripts/ui/rpg_pause_menu.gd")

func _initialize() -> void:
	var errors: Array[String] = []
	_test_content_registries(errors)
	_test_inventory_migration(errors)
	_test_crafting(errors)
	_test_special_runtime(errors)
	_test_gadget_runtime(errors)
	_test_menu_contract(errors)
	if errors.is_empty():
		print("SPECIAL_GADGET_CRAFTING_SMOKE: PASS")
		quit(0)
		return
	for text: String in errors:
		printerr("SPECIAL_GADGET_CRAFTING_SMOKE: " + text)
	quit(1)

func _test_content_registries(errors: Array[String]) -> void:
	_expect(GADGETS.count() == 12, "expected exactly 12 initial combat gadgets", errors)
	_expect(CRAFTING.count() == 12, "expected exactly 12 initial crafting recipes", errors)
	_expect(EQUIPMENT.catalog_count() >= 24, "equipment catalog has fewer than 24 meaningful pieces", errors)
	_expect(EQUIPMENT.slot_ids().size() == 6, "equipment no longer exposes six trainer slots", errors)
	_expect(ITEMS.material_ids().size() >= 9, "crafting material registry is incomplete", errors)
	_expect(ITEMS.gadget_ids().size() == GADGETS.count(), "item and gadget registries disagree", errors)
	for gadget_id: String in GADGETS.ids():
		_expect(not GADGETS.info(gadget_id).is_empty(), "missing gadget data: " + gadget_id, errors)
		_expect(str(ITEMS.info(gadget_id).get("category", "")) == "gadget", "gadget is not represented in inventory: " + gadget_id, errors)

func _test_inventory_migration(errors: Array[String]) -> void:
	var old_inventory: Dictionary = {"capture_modules":2,"regenerators":1,"sondas":1,"resonance_cells":0}
	var normalized: Dictionary = ITEMS.normalize_inventory(old_inventory)
	_expect(int(normalized.get("capture_modules", 0)) == 2, "old core inventory count was lost", errors)
	_expect(normalized.has("alloy_scrap"), "old inventory did not gain crafting material keys", errors)
	_expect(normalized.has("phase_barrier"), "old inventory did not gain gadget keys", errors)

func _test_crafting(errors: Array[String]) -> void:
	var inventory: Dictionary = ITEMS.default_inventory()
	var before_barriers: int = ITEMS.count(inventory, "phase_barrier")
	var crafted: Dictionary = CRAFTING.craft(inventory, "craft_phase_barrier", 0)
	_expect(bool(crafted.get("crafted", false)), "basic phase barrier recipe could not be crafted", errors)
	var updated: Dictionary = crafted.get("inventory", {}) as Dictionary
	_expect(ITEMS.count(updated, "phase_barrier") == before_barriers + 1, "crafting did not add the gadget output", errors)
	var blocked_inventory: Dictionary = ITEMS.default_inventory()
	blocked_inventory["copper_coil"] = 99
	blocked_inventory["charged_crystal"] = 99
	var blocked: Dictionary = CRAFTING.craft(blocked_inventory, "craft_overload_coil", 0)
	_expect(not bool(blocked.get("crafted", false)), "Technician gate did not block an advanced recipe", errors)
	var unlocked: Dictionary = CRAFTING.craft(blocked_inventory, "craft_overload_coil", 2)
	_expect(bool(unlocked.get("crafted", false)), "Technician investment did not unlock the advanced recipe", errors)

func _test_special_runtime(errors: Array[String]) -> void:
	var member: Dictionary = STATE.make_member("Luzik", 20, 1)
	var party: Array = [member]
	var screen: Control = BATTLE.new()
	screen.setup(party, 0, 20, "Wahlik", 10, ITEMS.default_inventory(), PROGRESSION.default_talents(), EQUIPMENT.default_loadout())
	var special: Dictionary = screen._special_move_data()
	_expect(not special.is_empty(), "level-20 member has no runtime special move", errors)
	_expect((screen.player_data.get("moves", []) as Array).size() == 5, "battle runtime does not expose 4+1 move data", errors)
	var before_focus: int = screen.trainer_focus
	screen._queue_special()
	_expect(screen.pending_special, "special move was not queued", errors)
	_expect(screen.pending_move_index == 4, "special move does not use the fifth runtime slot", errors)
	_expect(screen.trainer_focus < before_focus, "special move did not reserve Focus", errors)
	var lines: Array[String] = []
	screen._execute_pending_move(lines)
	_expect(bool(screen.used_special_uids.get(str(member.get("uid", "")), false)), "special usage was not locked per creature", errors)
	screen.free()

func _test_gadget_runtime(errors: Array[String]) -> void:
	var member: Dictionary = STATE.make_member("Luzik", 20, 1)
	var inventory: Dictionary = ITEMS.default_inventory()
	inventory["mist_projector"] = 1
	var screen: Control = BATTLE.new()
	screen.setup([member], 0, 20, "Wahlik", 8, inventory, PROGRESSION.default_talents(), EQUIPMENT.default_loadout())
	var before: int = ITEMS.count(screen.inventory, "mist_projector")
	screen._use_gadget(1)
	_expect(ITEMS.count(screen.inventory, "mist_projector") == before - 1, "combat gadget was not consumed", errors)
	_expect(int(screen.enemy_statuses.get("soaked", 0)) > 0, "mist projector did not apply MOKRY status", errors)
	screen.free()

func _test_menu_contract(errors: Array[String]) -> void:
	var menu: Control = MENU.new()
	menu.setup(STATE.new_profile("Luzik"))
	_expect(menu.has_signal("craft_requested"), "RPG menu has no crafting signal", errors)
	menu.section = "crafting"
	_expect(menu._section_count() == CRAFTING.count(), "crafting menu does not expose all recipes", errors)
	menu.section = "moves"
	_expect(menu._section_count() == 4, "4+1 presentation changed the four configurable active slots", errors)
	menu.free()

func _expect(condition: bool, message: String, errors: Array[String]) -> void:
	if not condition:
		errors.append(message)
