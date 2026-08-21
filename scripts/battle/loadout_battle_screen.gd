extends "res://scripts/battle/rpg_battle_screen.gd"

const LEARNSETS = preload("res://scripts/data/learnset_db.gd")

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
	if move_data.size() == LEARNSETS.ACTIVE_LIMIT:
		player_data["moves"] = move_data
	var special_id: String = LEARNSETS.normalize_special(
		str(member.get("name", "")),
		maxi(1, int(member.get("level", 1))),
		member.get("special_move_id", ""),
		player_data
	)
	player_data["special_move_id"] = special_id
