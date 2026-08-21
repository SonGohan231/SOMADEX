extends SceneTree

const BATTLE = preload("res://scripts/battle/campaign_wild_battle_screen.gd")
const STATE = preload("res://scripts/core/game_state.gd")
const PROGRESSION = preload("res://scripts/data/progression_db.gd")
const EQUIPMENT = preload("res://scripts/data/equipment_db.gd")

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	root.size = Vector2i(360, 800)
	var screen: Control = BATTLE.new()
	root.add_child(screen)
	screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var party: Array = [STATE.make_member("Nucik", 5, 1)]
	screen.setup(
		party,
		0,
		1,
		"Wahlik",
		5,
		{},
		PROGRESSION.default_talents(),
		EQUIPMENT.default_loadout()
	)
	await create_timer(0.55).timeout
	RenderingServer.force_draw()
	await process_frame
	var image: Image = root.get_viewport().get_texture().get_image()
	var output := ProjectSettings.globalize_path("res://build/visual_qa/current_battle.png")
	DirAccess.make_dir_recursive_absolute(output.get_base_dir())
	var error := image.save_png(output)
	if error != OK:
		push_error("Failed to save battle runtime screenshot: %s" % error)
		quit(1)
		return
	print("BATTLE VISUAL SNAPSHOT: ", output, " ", image.get_width(), "x", image.get_height())
	quit(0)
