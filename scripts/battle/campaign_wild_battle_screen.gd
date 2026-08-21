extends "res://scripts/battle/loadout_battle_screen.gd"

const CAMPAIGN_BALANCE = preload("res://scripts/data/campaign_battle_balance.gd")

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
	super.setup(
		party_data,
		start_active_index,
		level,
		enemy_name,
		encounter_level,
		battle_inventory,
		talent_levels,
		loadout
	)
	var enemy_base_hp: int = int(enemy_data.get("max_hp", 20))
	enemy_max_hp = CAMPAIGN_BALANCE.scaled_max_hp(enemy_base_hp, enemy_level)
	enemy_hp = enemy_max_hp
