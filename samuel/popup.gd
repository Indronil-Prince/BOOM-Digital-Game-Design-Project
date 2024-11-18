extends Popup

var is_blender_on = false  # State tracker for the blender
var button: Button
var audio: AudioStreamPlayer3D
var vibration: Node3D

var notifySamuelButton: Button
var notifySamuelAudioStreamPlayer: AudioStreamPlayer

var play_count = 0  # Counter to track how many times the audio has played
const MAX_PLAY_COUNT = 3  # Number of times to repeat
var notifySamuelForBlender: bool

signal blender_turned_on

func _ready():
	# Assuming the button is a direct child of the popup, adjust the path as necessary
	button = $VBoxContainer/Button
	notifySamuelButton = $VBoxContainer/notifySamuelButton
	notifySamuelAudioStreamPlayer = $VBoxContainer/AudioStreamPlayer
	#button = get_node("/root/Node3D/BlenderPopup/VBoxContainer/Button")
	button.text = "Turn On!"
	#button.connect("pressed",  Callable(button, "_on_Button_pressed"))
	notifySamuelForBlender = false

func _on_Button_pressed():
	is_blender_on = !is_blender_on  # Toggle state
	audio = get_node("/root/Node3D/kitchen/MeshInstance3D/BlenderTable/Blender12/AudioStreamPlayer3D")
	vibration = get_node("/root/Node3D/kitchen/MeshInstance3D/BlenderTable/Blender12/vibration")

	if is_blender_on:
		button.text = "Turn Off" 
		audio.play()
		vibration.visible = true
		emit_signal("blender_turned_on")
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


func _on_notify_samuel_button_pressed() -> void:
	notifySamuelForBlender = true
	play_count = 1 
	var turning_on_blender_audio = load("res://Turning_On_The_Blender.mp3") as AudioStream
	notifySamuelAudioStreamPlayer.connect("finished", Callable(self, "_on_audio_finished"))
	notifySamuelAudioStreamPlayer.stream = turning_on_blender_audio
	notifySamuelAudioStreamPlayer.play()

func _on_audio_finished() -> void:
	if play_count < MAX_PLAY_COUNT:
		delay(4)
		play_count += 1
		notifySamuelAudioStreamPlayer.play()
	else:
		print("Audio finished playing 3 times!")

func delay(seconds) ->void:
	print("Inside delay")
	var timer = Timer.new()
	timer.wait_time = seconds
	timer.one_shot = false
	add_child(timer)
	timer.start()
	await timer.timeout  # Wait for the timeout signal
	
