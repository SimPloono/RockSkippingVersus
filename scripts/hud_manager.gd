extends Node

const DAMAGE_NUMBER = preload("uid://bj7ojkkbj0pw5")
const WOOSH_SOUND: AudioStream = preload("uid://crv4a80w64s7c")

var close_dodge_counter: int = 0

var camera: Camera3D

func handle_close_dodge(position: Vector3) -> void:
	AudioManager.play_audio_one_shot(WOOSH_SOUND)
	close_dodge_counter += 1
	var damage_number_instance: DamageNumber = DAMAGE_NUMBER.instantiate()
	add_child(damage_number_instance)
	damage_number_instance.global_position = position
	DifficultyManager.speed_boost(1.4, 1.5)
	
	if camera and camera.has_method("add_trauma"):
		camera.add_trauma(0.6)

func handle_obstacle_hit(obstacle: Obstacle) -> void:
	if obstacle.hurt_sound:
		AudioManager.play_audio_one_shot(obstacle.hurt_sound, -7.0)
	if camera and camera.has_method("add_trauma"):
		camera.add_trauma(0.8)
	HitlagManager.hitlag(0.1, 0.8)
	DifficultyManager.speed_dip()
