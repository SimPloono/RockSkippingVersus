extends Node3D
## Skipping Stone movement
## - Moves only left/right (X axis)
## - Z stays locked (world/floor scrolls past the stone instead)
## - Floor is a flat plane always at y = 0, so we track height manually
##   instead of relying on physics collision / is_on_floor()
## - Constantly bounces a little (like a skipping stone)
## - Space gives a bigger hop to dodge obstacles
## - Mesh constantly tumbles around its own axis (like a stone skipping/rolling)
@onready var stone: Node3D = $stone
@export var move_speed: float = 3.0
@export var auto_hop_strength: float = 4.0     # height of the constant little bounce
@export var dodge_jump_strength: float = 9.0   # height of the Space dodge-jump
@export var gravity: float = 20.0
@export var clamp_x: bool = true
@export var min_x: float = -4.0
@export var max_x: float = 4.0
@export var spin_speed_deg: float = 1800     # degrees per second, tumble around X axis
@export var jump_buffer_time: float = 0.15   # seconds a Space press is "remembered" before landing
@export var coyote_time: float = 0.15        # seconds after leaving the floor a press still counts

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
	# --- Buffer the jump input so an early press still counts ---
	if Input.is_action_just_pressed("ui_accept"):
		_jump_buffer_timer = jump_buffer_time
	else:
		_jump_buffer_timer -= delta
	# --- Gravity / grounding, based on fixed floor height ---
	if global_position.y > GROUND_Y or _vertical_velocity > 0.0:
		_vertical_velocity -= gravity * delta
		if _grounded:
			# just left the floor this frame, start the coyote window
			_coyote_timer = coyote_time
		else:
			_coyote_timer -= delta
		_grounded = false
	else:
		_grounded = true
		_coyote_timer = 0.0
		global_position.y = GROUND_Y
		# constant little bounce while grounded, unless a buffered dodge jump is waiting
		if _jump_buffer_timer > 0.0:
			_vertical_velocity = dodge_jump_strength
			_jump_buffer_timer = 0.0
		else:
			_vertical_velocity = auto_hop_strength
	# --- Dodge jump (bigger hop): allowed while grounded OR still within coyote time ---
	if _jump_buffer_timer > 0.0 and (_grounded or _coyote_timer > 0.0):
		_vertical_velocity = dodge_jump_strength
		_jump_buffer_timer = 0.0
		_coyote_timer = 0.0
		_grounded = false
	# --- Left/Right movement ---
	var input_dir := Input.get_axis("move_left", "move_right")
	var new_x := global_position.x + input_dir * move_speed * delta
	if clamp_x:
		new_x = clamp(new_x, min_x, max_x)
	# --- Apply movement ---
	global_position.x = new_x
	global_position.y += _vertical_velocity * delta
	global_position.z = _locked_z  # locked, never changes
	# --- Constant tumble/spin (visual only, doesn't affect movement) ---
	stone.rotate_y(deg_to_rad(spin_speed_deg) * delta)
