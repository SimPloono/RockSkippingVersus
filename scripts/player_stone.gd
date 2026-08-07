extends Node3D
## Skipping Stone movement
## - Moves only left/right (X axis)
## - Z stays locked (world/floor scrolls past the stone instead)
## - Floor is a flat plane always at y = 0, so we track height manually
##   instead of relying on physics collision / is_on_floor()
## - Constantly bounces a little (like a skipping stone)
## - Space gives a bigger hop to dodge obstacles
## - Mesh constantly tumbles around its own axis (like a stone skipping/rolling)
##   Tumble speed scales with the current world scroll speed (faster run = faster spin)

@onready var stone: Node3D = $stone

const SPLASH_SOUND: AudioStream = preload("uid://bin4vfaguxdrp")
const SPLASH_JUMP_SOUND: AudioStream = preload("uid://5acdih61fnxh")

@export_group("Movement")
@export var move_speed: float = 3.0
@export var clamp_x: bool = true
@export var min_x: float = -4.0
@export var max_x: float = 4.0

@export_group("Jumping")
@export var auto_hop_strength: float = 4.0
@export var dodge_jump_strength: float = 9.0
@export var gravity: float = 20.0
@export var jump_buffer_time: float = 0.15
@export var coyote_time: float = 0.15

@export_group("Visuals")
@export var base_spin_speed_deg: float = 1800   # spin at the run's starting speed
@export var spawner: Node                       # assign your ObjectSpawner here

const GROUND_Y: float = 0.08

var _locked_z: float
var _vertical_velocity: float = 0.0
var _grounded: bool = true
var _jump_buffer_timer: float = 0.0
var _coyote_timer: float = 0.0


func _ready() -> void:
	_locked_z = global_position.z
	global_position.y = GROUND_Y


func _physics_process(delta: float) -> void:
	_update_jump_buffer(delta)
	_update_vertical_motion(delta)
	_try_dodge_jump()
	_update_horizontal_motion(delta)
	_apply_transform()
	_update_visuals(delta)


## --- Input buffering ---------------------------------------------------

func _update_jump_buffer(delta: float) -> void:
	if Input.is_action_just_pressed("jump"):
		_jump_buffer_timer = jump_buffer_time
	else:
		_jump_buffer_timer -= delta


## --- Gravity / grounding -------------------------------------------------

func _update_vertical_motion(delta: float) -> void:
	var was_grounded := _grounded
	if global_position.y > GROUND_Y or _vertical_velocity > 0.0:
		_vertical_velocity -= gravity * delta
		if was_grounded:
			_coyote_timer = coyote_time
		else:
			_coyote_timer -= delta
		_grounded = false
	else:
		_grounded = true
		_coyote_timer = 0.0
		global_position.y = GROUND_Y
		if not was_grounded:
			_on_landed()
		_vertical_velocity = auto_hop_strength


func _on_landed() -> void:
	AudioManager.play_random_one_shot([SPLASH_SOUND], -10)


## --- Dodge jump ---------------------------------------------------

func _try_dodge_jump() -> void:
	if _jump_buffer_timer > 0.0 and (_grounded or _coyote_timer > 0.0):
		AudioManager.play_audio_one_shot(SPLASH_JUMP_SOUND)
		_vertical_velocity = dodge_jump_strength
		_jump_buffer_timer = 0.0
		_coyote_timer = 0.0
		_grounded = false


## --- Left/Right movement -------------------------------------------------

func _update_horizontal_motion(delta: float) -> void:
	var input_dir := Input.get_axis("move_left", "move_right")
	var new_x := global_position.x + input_dir * move_speed * delta
	if clamp_x:
		new_x = clamp(new_x, min_x, max_x)
	global_position.x = new_x


func _apply_transform() -> void:
	global_position.y += _vertical_velocity * _get_delta()
	global_position.z = _locked_z


func _get_delta() -> float:
	return get_physics_process_delta_time()


## --- Visuals (tumble/spin) -------------------------------------------------

func _update_visuals(delta: float) -> void:
	var spin_speed := _current_spin_speed_deg()
	stone.rotate_y(deg_to_rad(spin_speed) * delta)


func _current_spin_speed_deg() -> float:
	if not spawner or not spawner.has_method("get_current_move_speed"):
		return base_spin_speed_deg

	var current_speed: float = spawner.get_current_move_speed()
	var base_speed: float = spawner.base_move_speed
	if base_speed <= 0.0:
		return base_spin_speed_deg

	var speed_ratio: float = current_speed / base_speed
	return base_spin_speed_deg * speed_ratio * DifficultyManager.speed_multiplier
