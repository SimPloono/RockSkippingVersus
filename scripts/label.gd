extends Label

func _process(_delta: float) -> void:
	text = "Distance: %d m" % int(RunStats.get_distance_meters()) + "\n Speed: %f" % int(RunStats.get_current_speed())
