extends "res://scripts/battle/loadout_battle_screen.gd"

const CAMPAIGN_BALANCE = preload("res://scripts/data/campaign_battle_balance.gd")
const CAMPAIGN_CAPTURE = preload("res://scripts/data/campaign_capture_balance.gd")
const BATTLE_MUSIC = preload("res://scripts/audio/retro_music.gd")
const SCENE_TRANSITION = preload("res://scripts/ui/scene_transition.gd")

var _battle_music: Node = null

func setup(
	party_data: Array,
	start_active_index: int,
	level: int,
	enemy_name: String = "Wahlik",
	encounter_level: int = 3,
	battle_inventory: Dictionary = {},
	talent_levels: Dictionary = {},
	loadout: Dictionary = {}
) -> void:
	super.setup(party_data,start_active_index,level,enemy_name,encounter_level,battle_inventory,talent_levels,loadout)
	enemy_data = CAMPAIGN_CAPTURE.apply(enemy_data)
	var enemy_base_hp: int = int(enemy_data.get("max_hp", 20))
	enemy_max_hp = CAMPAIGN_BALANCE.scaled_max_hp(enemy_base_hp, enemy_level)
	enemy_hp = enemy_max_hp

func _ready() -> void:
	super._ready()
	_battle_music = BATTLE_MUSIC.new()
	add_child(_battle_music)
	_battle_music.play_theme("battle")
	var transition: Control = SCENE_TRANSITION.new()
	add_child(transition)
	transition.play_in(0.20)

func _draw() -> void:
	super._draw()
	draw_rect(Rect2(12, 745, 336, 20), Color(0.02,0.08,0.10,0.72))
	draw_rect(Rect2(12, 745, 336, 20), Color(0.25,0.68,0.66,0.30), false, 1.0)
	draw_string(font, Vector2(18,759), "RUCH · DRUŻYNA · TORBA · UCIECZKA", HORIZONTAL_ALIGNMENT_CENTER, 324, 7, Color("c8e4e1"))
