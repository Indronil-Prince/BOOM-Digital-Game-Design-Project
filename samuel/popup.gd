extends Popup

var is_blender_on = false  # State tracker for the blender
var button: Button
var audio: AudioStreamPlayer3D
var vibration: Node3D

func _ready():
	# Assuming the button is a direct child of the popup, adjust the path as necessary
	button = $VBoxContainer/Button
	#button = get_node("/root/Node3D/BlenderPopup/VBoxContainer/Button")
	button.text = "Turn On"
	#button.connect("pressed",  Callable(button, "_on_Button_pressed"))

func _on_Button_pressed():
	is_blender_on = !is_blender_on  # Toggle state
	audio = get_node("/root/Node3D/kitchen/MeshInstance3D/BlenderTable/Blender12/AudioStreamPlayer3D")
	vibration = get_node("/root/Node3D/kitchen/MeshInstance3D/BlenderTable/Blender12/vibration")
	
	if is_blender_on:
		button.text = "Turn Off" 
		audio.play()
		vibration.visible = true
	else:
		button.text =  "Turn On"
		audio.stop()
		vibration.visible = false
	# Here you can trigger actual functionality, like playing a sound
	if is_blender_on:
		print("Blender is turned ON")
		# Optional: Start a sound or animation
	else:
		print("Blender is turned OFF")
		# Optional: Stop the sound or animation
