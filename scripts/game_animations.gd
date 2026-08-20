extends "res://scripts/game_art.gd"

const ANIM_STATE = preload("res://scripts/core/game_state.gd")
const ANIM_ENCOUNTERS = preload("res://scripts/data/alpha1_encounter_db.gd")
const ANIM_BATTLE_SCREEN = preload("res://scripts/battle/rpg_battle_screen.gd")

func _start_battle(tile: Vector2i) -> void:
	ANIM_STATE.set_player_tile(profile, tile)
	var zone_id: String = str(profile.get("zone_id", "vela"))
	var encounter: Dictionary = ANIM_ENCOUNTERS.roll(zone_id, rng)
	var enemy_name: String = str(encounter.get("name", "Wahlik"))
	ANIM_STATE.add_seen(profile, enemy_name)
	if int(profile.get("quest_stage", 0)) == 1:
		profile["quest_stage"] = 2
	var screen: Control = ANIM_BATTLE_SCREEN.new()
	screen.setup(
		profile.get("party", []) as Array,
		ANIM_STATE.active_index(profile),
		int(profile.get("trainer_level", 1)),
		enemy_name,
		int(encounter.get("level", 3)),
		profile.get("inventory", {}) as Dictionary,
		profile.get("talents", {}) as Dictionary,
		profile.get("equipment", {}) as Dictionary
	)
	screen.finished.connect(_on_battle_finished)
	_switch_to(screen)
