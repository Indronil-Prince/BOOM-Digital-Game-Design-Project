extends MeshInstance3D

func _ready():
	# Assuming you have a model named 'room_model.gltf' in your project folder
	var model = load("res://Bed_single.glb")
	var model_instance = MeshInstance3D.new()	model_instance.mesh = model
	add_child(model_instance)
	model_instance.translate(Vector3(0, 0, 0))  # Adjust position as necessary

	setup_lighting()

func setup_lighting():
	var light = DirectionalLight3D.new()
	add_child(light)
	light.rotate_x(deg_to_rad(-45))  # Example rotation to direct the light downwards
