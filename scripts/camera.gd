@tool
class_name Camera
extends Camera3D

@onready var postprocess: MeshInstance3D = $Postprocess

@export var shake_decay: float = 2.5
@export var max_offset: Vector3 = Vector3(0.2, 0.2, 0.0)
@export var max_roll: float = 0.15 # radians

var _trauma: float = 0.0
var _noise: FastNoiseLite = FastNoiseLite.new()
var _noise_time: float = 0.0

var _base_position: Vector3
var _base_rotation: Vector3

func _ready() -> void:
	_noise.noise_type = FastNoiseLite.TYPE_PERLIN
	_noise.frequency = 4.0
	_base_position = position
	_base_rotation = rotation
	HudManager.camera = self

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
		
	if _trauma > 0.0:
		_trauma = max(_trauma - shake_decay * delta, 0.0)
		var shake: float = _trauma * _trauma # ease-in for a snappier feel

		_noise_time += delta * 15.0

		var offset_x: float = max_offset.x * shake * _noise.get_noise_2d(_noise_time, 0.0)
		var offset_y: float = max_offset.y * shake * _noise.get_noise_2d(_noise_time, 100.0)
		var offset_z: float = max_offset.z * shake * _noise.get_noise_2d(_noise_time, 200.0)
		var roll: float = max_roll * shake * _noise.get_noise_2d(_noise_time, 300.0)

		position = _base_position + Vector3(offset_x, offset_y, offset_z)
		rotation = _base_rotation + Vector3(0.0, 0.0, roll)
	else:
		position = _base_position
		rotation = _base_rotation

## Call this to trigger shake. amount is 0-1, additive so multiple hits can stack.
func add_trauma(amount: float = 0.9) -> void:
	_trauma = clamp(_trauma + amount, 0.0, 1.0)

## Call this if you move the camera manually elsewhere (e.g. following a target)
## so shake offsets apply relative to the new base transform.
func update_base_transform() -> void:
	_base_position = position
	_base_rotation = rotation
