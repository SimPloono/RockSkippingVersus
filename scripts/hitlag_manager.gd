extends Node

var _timer: float = 0.0
var _active: bool = false

func hitlag(duration: float = 0.08, scale: float = 0.05) -> void:
	_timer = duration
	_active = true
	Engine.time_scale = scale

func _process(delta: float) -> void:
	if not _active:
		return
	# delta here is already scaled by Engine.time_scale, so unscale it
	# to count real elapsed time, not slowed time.
	var real_delta: float = delta / Engine.time_scale
	_timer -= real_delta
	if _timer <= 0.0:
		Engine.time_scale = 1.0
		_active = false
