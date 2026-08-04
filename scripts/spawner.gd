extends Node3D
## Object Spawner
## - Spawns objects at a random X position, fixed Y and Z (the spawn line)
## - Spawned objects are expected to move themselves (e.g. toward the player
##   along Z each frame using their own `move_speed` variable)
## - The move_speed assigned to new spawns keeps ramping up the longer the run
##   goes (no cap), with a bit of random variance per object
@export var object_scenes: Array[PackedScene] = []   # drag your obstacle .tscn files here
@export var spawn_z: float = -40.0     # fixed Z distance where objects appear
@export var spawn_y: float = 0.08      # match your floor height
@export var min_x: float = -4.0
@export var max_x: float = 4.0
@export var spawn_interval_start: float = 1.5   # seconds between spawns at run start
@export var spawn_interval_min: float = 0.4     # fastest spawn rate at max difficulty
@export var base_move_speed: float = 6.0        # move_speed given to objects at run start
@export var speed_ramp_rate: float = 10.0       # move_speed gained per difficulty_ramp_time, keeps adding forever
@export var move_speed_variance: float = 1.5    # +/- random variation applied to each object's move_speed
@export var difficulty_ramp_time: float = 60.0  # seconds for spawn rate to reach its fastest, and speed reference window
@export var min_scale: float = 0.7   # random uniform scale range for spawned objects
@export var max_scale: float = 1.4
var _run_time: float = 0.0
var _spawn_timer: float = 0.0

func _ready() -> void:
	randomize()
	_spawn_timer = spawn_interval_start
	
	
func _process(delta: float) -> void:
	_run_time += delta
	_spawn_timer -= delta
	if _spawn_timer <= 0.0:
		_spawn_object()
		_spawn_timer = _current_spawn_interval()
func _difficulty_t() -> float:
	# 0.0 at run start, 1.0 once difficulty_ramp_time has passed (clamped - used for spawn rate only)
	return clamp(_run_time / difficulty_ramp_time, 0.0, 1.0)
func _current_spawn_interval() -> float:
	return lerp(spawn_interval_start, spawn_interval_min, _difficulty_t())
func _current_move_speed() -> float:
	# NOT clamped - keeps climbing for as long as the run continues
	var t := _run_time / difficulty_ramp_time
	return base_move_speed + speed_ramp_rate * t
func _spawn_object() -> void:
	if object_scenes.is_empty():
		push_warning("Spawner has no object_scenes assigned.")
		return
	var scene: PackedScene = object_scenes[randi() % object_scenes.size()]
	var instance := scene.instantiate()
	get_tree().current_scene.add_child(instance)
	var x := randf_range(min_x, max_x)
	instance.global_position = Vector3(x, spawn_y, spawn_z)
	# Random uniform scale so objects vary in size
	var s := randf_range(min_scale, max_scale)
	instance.scale = Vector3(s, s, s)
	# Slight random rotation around Y so objects don't all face the same way
	instance.rotation.y = randf_range(0.0, TAU)
	# Assign the current ramped-up speed, with a bit of random per-object variance
	var speed := _current_move_speed() + randf_range(-move_speed_variance, move_speed_variance)
	speed = max(speed, 0.5)  # safety floor so variance can't make an object stall or go negative
	instance.set("move_speed", speed)
