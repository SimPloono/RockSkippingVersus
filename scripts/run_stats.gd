extends Node

var distance_traveled: float = 0.0

# Reference to whatever currently defines "world scroll speed" —
# assign this once from your ObjectSpawner (or pass the speed in directly).
var spawner: Node

func _process(delta: float) -> void:
	if not spawner:
		return
	var effective_speed: float = spawner.get_current_move_speed()
	distance_traveled += effective_speed * delta

func reset() -> void:
	distance_traveled = 0.0

func get_distance_meters() -> float:
	return distance_traveled
	
func get_current_speed() -> float:
	return spawner.get_current_move_speed()
