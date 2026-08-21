extends "res://scripts/battle/rpg_battle_screen.gd"

const LEARNSETS = preload("res://scripts/data/learnset_db.gd")
const LOADOUT_MOVES = preload("res://scripts/data/move_db.gd")
const GADGETS = preload("res://scripts/data/gadget_db.gd")

const SPECIAL_BASE_FOCUS_COST: int = 2

var used_special_uids: Dictionary = {}
var pending_special: bool = false
var pending_special_uid: String = ""
var pending_special_focus: int = 0

func _refresh_rpg_identity() -> void:
	super._refresh_rpg_identity()
	_apply_player_loadout()

func _load_active_member() -> void:
	super._load_active_member()
	_apply_player_loadout()

func _apply_player_loadout() -> void:
	var member: Dictionary = _active_member()
	if member.is_empty() or player_data.is_empty():
		return
	var move_data: Array[Dictionary] = LEARNSETS.active_move_data(member, player_data)
	var special_id: String = LEARNSETS.normalize_special(
		str(member.get("name", "")),
		maxi(1, int(member.get("level", 1))),
		member.get("special_move_id", ""),
		player_data
	)
	player_data["special_move_id"] = special_id
	if move_data.size() == LEARNSETS.ACTIVE_LIMIT:
		player_data["moves"] = move_data
	if not special_id.is_empty() and LOADOUT_MOVES.has(special_id):
		var all_moves: Array = player_data.get("moves", []) as Array
		if all_moves.size() == LEARNSETS.ACTIVE_LIMIT:
			all_moves.append(LOADOUT_MOVES.info(special_id))
			player_data["moves"] = all_moves

func _draw() -> void:
	super._draw()
	if mode == "bag" and not battle_done:
		_draw_gadget_entry()
	if mode == "gadgets" and not battle_done:
		_draw_gadget_menu()

func _draw_move_menu() -> void:
	super._draw_move_menu()
	var rect: Rect2 = _special_rect()
	var special: Dictionary = _special_move_data()
	var uid: String = _active_uid()
	var used: bool = bool(used_special_uids.get(uid, false))
	var cost: int = _special_focus_cost()
	var available: bool = not special.is_empty() and not used and trainer_focus >= cost
	draw_rect(rect, Color("3d3158") if available else Color("17252d"))
	draw_rect(rect, Color("b596ff") if available else Color("44545a"), false, 2.0)
	var label: String = "SPECJALNY · odblokowanie Lv.%d" % LEARNSETS.SPECIAL_UNLOCK_LEVEL
	if not special.is_empty():
		label = "★ %s · F%d" % [str(special.get("name", "SPECJALNY")), cost]
	if used:
		label = "★ SPECJALNY · UŻYTY W TEJ WALCE"
	draw_string(font, rect.position + Vector2(8, 22), label, HORIZONTAL_ALIGNMENT_CENTER, rect.size.x - 16, 8, Color("f3edff") if available else Color("75868b"))

func _draw_gadget_entry() -> void:
	var rect: Rect2 = _gadget_entry_rect()
	var total: int = 0
	for gadget_id: String in GADGETS.ids():
		total += ITEMS.count(inventory, gadget_id)
	draw_rect(rect, Color("453a1d") if total > 0 else Color("17252d"))
	draw_rect(rect, Color("e0c65e") if total > 0 else Color("44545a"), false, 2.0)
	draw_string(font, rect.position + Vector2(8, 22), "GADŻETY BOJOWE · %d szt.  ›" % total, HORIZONTAL_ALIGNMENT_CENTER, rect.size.x - 16, 8, Color("fff4bd") if total > 0 else Color("75868b"))

func _draw_gadget_menu() -> void:
	var ids: Array[String] = GADGETS.quick_ids(6)
	for i: int in range(6):
		var rect: Rect2 = _list_rect(i)
		var active: bool = i == selected
		draw_rect(rect, Color("40391f") if active else Color("0e2831"))
		draw_rect(rect, Color("e0c65e") if active else Color("2d5059"), false, 1.0)
		if i >= ids.size():
			continue
		var gadget_id: String = ids[i]
		var data: Dictionary = GADGETS.info(gadget_id)
		var count: int = ITEMS.count(inventory, gadget_id)
		var focus_cost: int = int(data.get("focus", 0))
		draw_string(font, rect.position + Vector2(8, 17), "%s ×%d · F%d" % [str(data.get("name", gadget_id)), count, focus_cost], HORIZONTAL_ALIGNMENT_LEFT, 310, 8, Color("fff8d3") if count > 0 else Color("65777b"))

func _special_rect() -> Rect2:
	return Rect2(16, 758, 328, 34)

func _gadget_entry_rect() -> Rect2:
	return Rect2(16, 758, 328, 34)

func _active_uid() -> String:
	var member: Dictionary = _active_member()
	return str(member.get("uid", _active_name()))

func _special_move_data() -> Dictionary:
	var moves: Array = player_data.get("moves", []) as Array
	if moves.size() <= LEARNSETS.ACTIVE_LIMIT:
		return {}
	var raw: Variant = moves[LEARNSETS.ACTIVE_LIMIT]
	if typeof(raw) != TYPE_DICTIONARY:
		return {}
	return (raw as Dictionary).duplicate(true)

func _special_focus_cost() -> int:
	var discount: int = maxi(0, int(gear_bonuses.get("special_focus_discount", 0)))
	return maxi(0, SPECIAL_BASE_FOCUS_COST - discount)

func _queue_special() -> void:
	var special: Dictionary = _special_move_data()
	if special.is_empty():
		log_text = "Zdolność specjalna nie jest jeszcze odblokowana."
		queue_redraw()
		return
	var uid: String = _active_uid()
	if bool(used_special_uids.get(uid, false)):
		log_text = "Ten partner wykorzystał już swój ruch specjalny w tej walce."
		queue_redraw()
		return
	var cost: int = _special_focus_cost()
	if trainer_focus < cost:
		log_text = "Ruch specjalny wymaga %d Focus." % cost
		queue_redraw()
		return
	trainer_focus -= cost
	pending_special_focus = cost
	pending_special = true
	pending_special_uid = uid
	pending_move_index = LEARNSETS.ACTIVE_LIMIT
	pending_damage_bonus = 0
	mode = "trainer"
	selected = 5
	log_text = "%s przygotowuje SPECJALNY: %s. Możesz dodać komendę trenera." % [_active_name(), str(special.get("name", "ruch"))]
	queue_redraw()

func _cancel_pending_special() -> void:
	if not pending_special:
		return
	trainer_focus = mini(trainer_focus_max, trainer_focus + pending_special_focus)
	pending_special = false
	pending_special_uid = ""
	pending_special_focus = 0

func _execute_pending_move(lines: Array[String]) -> void:
	if pending_special:
		used_special_uids[pending_special_uid] = true
		lines.append("REZONANS 4+1: %s uruchamia zdolność specjalną." % _active_name())
	super._execute_pending_move(lines)
	pending_special = false
	pending_special_uid = ""
	pending_special_focus = 0

func _use_gadget(index: int) -> void:
	var ids: Array[String] = GADGETS.quick_ids(6)
	if index < 0 or index >= ids.size():
		return
	var gadget_id: String = ids[index]
	var data: Dictionary = GADGETS.info(gadget_id)
	if data.is_empty():
		return
	if ITEMS.count(inventory, gadget_id) <= 0:
		log_text = "Brak: %s." % str(data.get("name", gadget_id))
		queue_redraw()
		return
	var focus_cost: int = maxi(0, int(data.get("focus", 0)))
	if trainer_focus < focus_cost:
		log_text = "Gadżet wymaga %d Focus." % focus_cost
		queue_redraw()
		return
	if not ITEMS.consume(inventory, gadget_id):
		return
	trainer_focus -= focus_cost
	var lines: Array[String] = ["Gadżet: %s." % str(data.get("name", gadget_id))]
	var effect: String = str(data.get("effect", ""))
	var value: int = maxi(0, int(data.get("value", 0)))
	var power_bonus: int = maxi(0, int(gear_bonuses.get("gadget_power_bonus", 0))) + maxi(0, int(talent_bonuses.get("gadget_power_bonus", 0)))
	var status_id: String = str(data.get("status", ""))
	if effect == "guard":
		player_guard = true
		lines.append("Bariera osłania aktywnego partnera.")
	if effect == "enemy_status":
		RPG_STATUS.apply(enemy_statuses, status_id, maxi(1, value))
		lines.append("%s otrzymuje status %s." % [str(enemy_data.get("name", "przeciwnik")), str(RPG_STATUS.info(status_id).get("name", status_id.to_upper()))])
	if effect == "player_status":
		RPG_STATUS.apply(player_statuses, status_id, maxi(1, value))
		lines.append("%s otrzymuje efekt %s." % [_active_name(), str(RPG_STATUS.info(status_id).get("name", status_id.to_upper()))])
	if effect == "damage" or effect == "damage_status":
		var damage: int = value + power_bonus * 2
		enemy_hp = maxi(0, enemy_hp - damage)
		flash_enemy_until = Time.get_ticks_msec() + 170
		lines.append("Impuls gadżetu: -%d HP." % damage)
		if not status_id.is_empty():
			RPG_STATUS.apply(enemy_statuses, status_id)
	if effect == "heal":
		var before: int = player_hp
		player_hp = mini(player_max_hp, player_hp + value + power_bonus)
		lines.append("Wsparcie: +%d HP." % (player_hp - before))
	if effect == "focus":
		var before_focus: int = trainer_focus
		trainer_focus = mini(trainer_focus_max, trainer_focus + value + int(power_bonus / 2))
		lines.append("Focus: +%d." % (trainer_focus - before_focus))
	if effect == "stability":
		if player_stability_max > 0:
			var before_stability: int = player_stability
			player_stability = mini(player_stability_max, player_stability + value + power_bonus * 2)
			lines.append("Stabilność: +%d." % (player_stability - before_stability))
		else:
			lines.append("Stabilność nie jest aktywna w tym typie pojedynku.")
	if enemy_hp <= 0:
		_win(lines)
	else:
		_enemy_turn(lines)
		if not battle_done:
			_end_round(lines)
		if not battle_done:
			_handle_faint(lines)
	mode = "root"
	selected = 0
	log_text = "\n".join(lines)
	queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
	if visual_queue.blocks_input():
		return
	if event is InputEventKey:
		var key_event: InputEventKey = event as InputEventKey
		if key_event.pressed and not key_event.echo:
			if mode == "moves" and key_event.keycode == KEY_Q:
				_queue_special()
				return
			if mode == "trainer" and pending_special and key_event.keycode in [KEY_ESCAPE, KEY_X]:
				_cancel_pending_special()
				super._unhandled_input(event)
				return
			if mode == "gadgets":
				if key_event.keycode in [KEY_ESCAPE, KEY_X]:
					mode = "bag"
					selected = 0
				elif key_event.keycode in [KEY_UP, KEY_W]:
					selected = (selected + 5) % 6
				elif key_event.keycode in [KEY_DOWN, KEY_S]:
					selected = (selected + 1) % 6
				elif key_event.keycode in [KEY_ENTER, KEY_SPACE, KEY_Z]:
					_use_gadget(selected)
				queue_redraw()
				return
	if event is InputEventScreenTouch:
		var touch: InputEventScreenTouch = event as InputEventScreenTouch
		if touch.pressed:
			var pos: Vector2 = touch.position
			if mode == "moves" and _special_rect().has_point(pos):
				_queue_special()
				return
			if mode == "bag" and _gadget_entry_rect().has_point(pos):
				mode = "gadgets"
				selected = 0
				queue_redraw()
				return
			if mode == "gadgets":
				for i: int in range(6):
					if _list_rect(i).has_point(pos):
						selected = i
						_use_gadget(i)
						return
	super._unhandled_input(event)
