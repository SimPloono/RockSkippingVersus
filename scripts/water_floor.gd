extends MeshInstance3D

var shader_material: ShaderMaterial

func _ready() -> void:
	shader_material = material_override
	print(shader_material.get_shader_parameter("scroll_speed"))

func _physics_process(delta: float) -> void:
	if shader_material:
		var speed := RunStats.get_current_speed()
		print(speed) # temporär, um zu sehen ob es je negativ wird
		var scroll_y: float = -0.03 * speed
		shader_material.set_shader_parameter("scroll_speed", Vector2(0, scroll_y))
