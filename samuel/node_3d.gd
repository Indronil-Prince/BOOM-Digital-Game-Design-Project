extends Node3D
 
var current_camera_index = 0
var cameras = []
 
func _ready():
	# Ensure the entire scene is visible
	self.show()
	print("Scene is running")
	# Initialize the array with camera nodes
	cameras = [$Camera3D, $Camera3D2]
	# Set the initial active camera
	cameras[current_camera_index].current = true
	set_children_visibility(self, true)
 
func set_children_visibility(node, visibility):
	for child in node.get_children():
		if child is MeshInstance3D:
			child.visible = visibility
		set_children_visibility(child, visibility)
func _process(delta: float) -> void:
	if Input.is_key_pressed(KEY_Z):
		toggle_camera()
func toggle_camera():
	# Deactivate the current camera
	cameras[current_camera_index].current = false
	current_camera_index = (current_camera_index + 1) % cameras.size()
	# Activate the new current camera
	cameras[current_camera_index].current = true
	print("Switched to: ", cameras[current_camera_index].name)
	#if cameras[current_camera_index].name == "Camera3D2":
		#$BlenderPopup.show()
