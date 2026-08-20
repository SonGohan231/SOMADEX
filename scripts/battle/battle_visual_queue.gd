extends RefCounted

const DURATIONS: Dictionary = {
	"attack": 0.38,
	"hurt": 0.28,
	"faint": 0.72,
	"special": 0.56
}

var _queue: Array[Dictionary] = []
var _active: Dictionary = {}
var _elapsed: float = 0.0

func enqueue(actor: String, state: String, move_type: String = "", magnitude: float = 1.0) -> void:
	var normalized: String = state if DURATIONS.has(state) else "special"
	_queue.append({
		"actor": actor,
		"state": normalized,
		"move_type": move_type,
		"magnitude": clampf(magnitude, 0.2, 3.0),
		"duration": float(DURATIONS[normalized])
	})
	if _active.is_empty():
		_advance()

func tick(delta: float) -> bool:
	if _active.is_empty():
		if _queue.is_empty():
			return false
		_advance()
	_elapsed += maxf(delta, 0.0)
	if _elapsed >= float(_active.get("duration", 0.1)):
		_advance()
	return not _active.is_empty() or not _queue.is_empty()

func clear() -> void:
	_queue.clear()
	_active.clear()
	_elapsed = 0.0

func blocks_input() -> bool:
	return not _active.is_empty() or not _queue.is_empty()

func state_for(actor: String) -> String:
	if str(_active.get("actor", "")) == actor:
		return str(_active.get("state", "idle"))
	return "idle"

func move_type_for(actor: String) -> String:
	if str(_active.get("actor", "")) == actor:
		return str(_active.get("move_type", ""))
	return ""

func magnitude_for(actor: String) -> float:
	if str(_active.get("actor", "")) == actor:
		return float(_active.get("magnitude", 1.0))
	return 1.0

func progress_for(actor: String) -> float:
	if str(_active.get("actor", "")) != actor:
		return 0.0
	var duration: float = maxf(0.001, float(_active.get("duration", 0.1)))
	return clampf(_elapsed / duration, 0.0, 1.0)

func pending_count() -> int:
	return _queue.size() + (0 if _active.is_empty() else 1)

func _advance() -> void:
	_elapsed = 0.0
	if _queue.is_empty():
		_active = {}
		return
	_active = _queue.pop_front()
