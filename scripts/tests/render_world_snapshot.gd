extends SceneTree

const WORLD = preload("res://scripts/world/sprite_campaign_world_screen.gd")

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	root.size = Vector2i(360, 800)
	var screen: Control = WORLD.new()
	root.add_child(screen)
	screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	screen.setup(
		"Nucik",
		Vector2i(7, 20),
		1,
		false,
		"vela",
		"Znajdź dzikiego Somaskana",
		{}
	)
	await process_frame
	await process_frame
	RenderingServer.force_draw()
	await process_frame
	var image: Image = root.get_viewport().get_texture().get_image()
	var output := ProjectSettings.globalize_path("res://build/visual_qa/current_world.png")
	DirAccess.make_dir_recursive_absolute(output.get_base_dir())
	var error := image.save_png(output)
	if error != OK:
		push_error("Failed to save runtime screenshot: %s" % error)
		quit(1)
		return
	print("RUNTIME VISUAL SNAPSHOT: ", output, " ", image.get_width(), "x", image.get_height())
	quit(0)
