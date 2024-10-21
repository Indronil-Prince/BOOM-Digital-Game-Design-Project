extends Node3D

func _ready():
	# Assuming you have a model named 'room_model.gltf' in your project folder
	var model = load("res://scene.gltf")

	setup_lighting()

func setup_lighting():
	var light = DirectionalLight3D.new()
	add_child(light)
	light.rotate_x(deg_to_rad(-45))  # Example rotation to direct the light downwards
