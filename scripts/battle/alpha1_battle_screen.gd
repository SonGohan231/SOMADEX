extends "res://scripts/battle/battle_screen.gd"

const ALPHA_ART = preload("res://scripts/data/monster_art_alpha.gd")

func _ready() -> void:
	super._ready()
	player_tex = ALPHA_ART.texture_for(_active_name())
	enemy_tex = ALPHA_ART.texture_for(str(enemy_data.get("name", "Wahlik")))
	queue_redraw()

func _load_active_member() -> void:
	super._load_active_member()
	if is_inside_tree():
		player_tex = ALPHA_ART.texture_for(_active_name())
