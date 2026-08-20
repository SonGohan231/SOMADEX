extends RefCounted

const SAVE_PATH: String = "user://somadex_save.json"

static func has_save() -> bool:
	return FileAccess.file_exists(SAVE_PATH)

static func save_game(data: Dictionary) -> bool:
	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		return false
	file.store_string(JSON.stringify(data))
	file.flush()
	file.close()
	return true

static func load_game() -> Dictionary:
	if not has_save():
		return {}
	var file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return {}
	var raw_text: String = file.get_as_text()
	file.close()
	var parsed: Variant = JSON.parse_string(raw_text)
	if typeof(parsed) != TYPE_DICTIONARY:
		return {}
	return (parsed as Dictionary).duplicate(true)
