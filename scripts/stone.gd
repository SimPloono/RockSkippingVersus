extends Node3D

@export var move_direction: Vector3 = Vector3.BACK
@export var move_speed: float = 10.0

func _physics_process(delta: float) -> void:
	global_position += move_direction * move_speed * delta
