class_name Obstacle
extends Node3D

@onready var close_dodge_hitbox: Area3D = $MeshInstance3D/CloseDodgeHitbox
@onready var hitbox: Area3D = $MeshInstance3D/Hitbox

@export var move_direction: Vector3 = Vector3.BACK
@export var move_speed: float = 10.0

signal close_dodged(position: Vector3)
signal hit_obstacle(obstacle: Obstacle)

@export var hurt_sound: AudioStream

func _ready() -> void:
	close_dodge_hitbox.area_entered.connect(_on_close_dodge_hitbox_area_entered)
	hitbox.area_entered.connect(_on_hitbox_area_entered)

func _physics_process(delta: float) -> void:
	global_position += move_direction * move_speed * DifficultyManager.speed_multiplier * delta

func _on_close_dodge_hitbox_area_entered(area: Area3D) -> void:
	var contact_point := (global_position + area.global_position) / 2.0
	close_dodged.emit(contact_point)
	close_dodge_hitbox.set_deferred("monitoring", false)

func _on_hitbox_area_entered(_area: Area3D) -> void:
	hit_obstacle.emit(self)
	hitbox.set_deferred("monitoring", false)
