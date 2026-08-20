extends "res://scripts/battle/battle_screen.gd"

const TRAINERS = preload("res://scripts/data/alpha1_trainer_db.gd")
const MONSTERS = preload("res://scripts/data/monster_db.gd")
const ALPHA_ART = preload("res://scripts/data/monster_art_alpha.gd")

var trainer_id: String = ""
var trainer_name: String = "Trener"
var trainer_title: String = "Pojedynek trenerski"
var enemy_team: Array = []
var enemy_team_index: int = 0
var trainer_reward_xp: int = 0
var enemy_switched_this_turn: bool = false

func setup_trainer(
	trainer_key: String,
	party_data: Array,
	start_active_index: int,
	level: int,
	battle_inventory: Dictionary,
	talent_levels: Dictionary,
	loadout: Dictionary
) -> void:
	var data: Dictionary = TRAINERS.info(trainer_key)
	trainer_id = trainer_key
	trainer_name = str(data.get("name", "Trener"))
	trainer_title = str(data.get("title", "Pojedynek trenerski"))
	trainer_reward_xp = TRAINERS.reward_xp(trainer_key)
	enemy_team = TRAINERS.party(trainer_key)
	enemy_team_index = 0
	var first_name: String = "Wahlik"
	var first_level: int = 3
	if not enemy_team.is_empty():
		var first_entry: Dictionary = enemy_team[0] as Dictionary
		first_name = str(first_entry.get("name", first_name))
		first_level = maxi(1, int(first_entry.get("level", first_level)))
	super.setup(
		party_data,
		start_active_index,
		level,
		first_name,
		first_level,
		battle_inventory,
		talent_levels,
		loadout
	)

func _ready() -> void:
	super._ready()
	player_tex = ALPHA_ART.texture_for(_active_name())
	enemy_tex = ALPHA_ART.texture_for(str(enemy_data.get("name", "Wahlik")))
	log_text = "%s · %s rozpoczyna pojedynek!" % [trainer_name, trainer_title]
	queue_redraw()

func _draw_background() -> void:
	super._draw_background()
	draw_string(font, Vector2(18, 44), "%s · %d/%d" % [trainer_name.to_upper(), enemy_team_index + 1, maxi(1, enemy_team.size())], HORIZONTAL_ALIGNMENT_LEFT, 220, 8, Color("d9c96c"))

func _use_bag(index: int) -> void:
	if index == 0:
		log_text = "Moduł Chwytu jest zablokowany w pojedynku trenerskim."
		queue_redraw()
		return
	super._use_bag(index)

func _try_escape() -> void:
	log_text = "Nie można wycofać się z rozpoczętego pojedynku trenerskiego."
	queue_redraw()

func _enemy_turn(lines: Array[String]) -> void:
	if enemy_switched_this_turn:
		enemy_switched_this_turn = false
		return
	super._enemy_turn(lines)

func _win(lines: Array[String]) -> void:
	if battle_done:
		return
	if enemy_team_index + 1 < enemy_team.size():
		_sync_active_member()
		enemy_team_index += 1
		var entry: Dictionary = enemy_team[enemy_team_index] as Dictionary
		var next_name: String = str(entry.get("name", "Wahlik"))
		enemy_data = MONSTERS.get_monster(next_name)
		enemy_level = maxi(1, int(entry.get("level", 3)))
		var enemy_base_hp: int = int(enemy_data.get("max_hp", 20))
		enemy_max_hp = enemy_base_hp + maxi(0, enemy_level - 3)
		enemy_hp = enemy_max_hp
		enemy_statuses.clear()
		enemy_guard = false
		enemy_tex = ALPHA_ART.texture_for(next_name)
		enemy_switched_this_turn = true
		lines.append("%s wysyła %s Lv.%d!" % [trainer_name, next_name, enemy_level])
		queue_redraw()
		return
	super._win(lines)

func _make_result(outcome: String, xp: int, captured_name: String = "") -> Dictionary:
	var result: Dictionary = super._make_result(outcome, xp, captured_name)
	result["battle_kind"] = "trainer"
	result["trainer_id"] = trainer_id
	result["trainer_name"] = trainer_name
	if outcome == "win":
		result["xp"] = trainer_reward_xp
		result["captured_name"] = ""
	return result
