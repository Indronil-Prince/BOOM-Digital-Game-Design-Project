extends Node3D

signal run
var soundWindow: Popup
var lightWindow: Popup
var tempWindow: Popup
var current_camera_index = 0
var cameras = []
var play: TextureButton
var playLabel: Label
var audio: AudioStreamPlayer
var volume_up_button : TextureButton
var volume_down_button: TextureButton
var lightPlayButton: TextureButton
var light_up_button : TextureButton 
var light_down_button : TextureButton 
var temp_up_button : TextureButton 
var temp_down_button : TextureButton 
var tempReading: Label
var light : OmniLight3D
var temp: TextureButton
var panel: Panel
var exc: Sprite3D
var soundSignifierLabel: Label
var lightSingnifierLabel: Label



var is_playing = false
var volume_step = 2.0
var intensity_step = 0.5
var min_intensity = 0.0
var max_intensity = 10.0
var roomTemp = 100

 
func _ready():
	# Ensure the entire scene is visible
	self.show()
	print("Scene is running")
	
	
	
	# Initialize the array with camera nodes
	cameras = [$Camera3D, $Camera3D2]
	# Set the initial active camera
	cameras[current_camera_index].current = true
	set_children_visibility(self, true)
	soundWindow = $living/MeshInstance3D/BassSpeakers12/Window/Popup
	lightWindow = $living/MeshInstance3D/LightMeter/LightWindow/LightPopup
	tempWindow = $living/MeshInstance3D/Thermostat/TempWindow/TempPopup
	play = $living/MeshInstance3D/BassSpeakers12/Window/Popup/PlayButton
	playLabel = $living/MeshInstance3D/BassSpeakers12/Window/Popup/PlayLabel
	audio = $living/MeshInstance3D/BassSpeakers12/AudioStreamPlayer
	light = $living/OmniLight3D
	temp = $living/MeshInstance3D/Thermostat/TempWindow/TempPopup/TempPlayButton
	volume_up_button = $living/MeshInstance3D/BassSpeakers12/Window/Popup/UpButton
	volume_down_button = $living/MeshInstance3D/BassSpeakers12/Window/Popup/DownButton
	light_up_button = $living/MeshInstance3D/LightMeter/LightWindow/LightPopup/LightUpButton
	light_down_button = $living/MeshInstance3D/LightMeter/LightWindow/LightPopup/LightDownButton
	temp_up_button = $living/MeshInstance3D/Thermostat/TempWindow/TempPopup/TempUpButton
	temp_down_button = $living/MeshInstance3D/Thermostat/TempWindow/TempPopup/TempDownButton
	tempReading = $living/MeshInstance3D/Thermostat/TempWindow/TempPopup/TempReading
	panel = $Dialog/Panel2
	exc = $CharacterBody3D/ExclamationSprite
	soundSignifierLabel = $living/MeshInstance3D/BassSpeakers12/Window/Popup/SoundSignifierLabel
	lightSingnifierLabel = $living/MeshInstance3D/LightMeter/LightWindow/LightPopup/lightSignifierLabel
	lightPlayButton = $living/MeshInstance3D/LightMeter/LightWindow/LightPopup/LightPlayButton
	
	var trimmedValue: String = "%0.2f" % light.light_energy
	lightSingnifierLabel.text = str(trimmedValue)
	lightSingnifierLabel.modulate = Color(1, 0, 0)
	
	audio.volume_db = 24
	soundSignifierLabel.text = str (audio.volume_db)
	soundSignifierLabel.modulate  = Color(1, 0, 0)
	
	
func set_children_visibility(node, visibility):
	for child in node.get_children():
		if child is MeshInstance3D:
			child.visible = visibility
		set_children_visibility(child, visibility)
		
func _process(delta: float) -> void:
	
	checkTemp()
	if Input.is_key_pressed(KEY_Z):
		toggle_camera()
	if Input.is_key_pressed(KEY_3):
		onKey3Pressed()
		
		#global_transform.origin = Vector3(6.752, 0.517, 9.221)

func _on_PlayButton_pressed():
	print("Playbutton pressed")
	if is_playing:
		audio.stop()
		is_playing = false  # Update the state to reflect that audio is stopped
		playLabel.text = "Play Music"
	else:
		audio.play()
		is_playing = true
		playLabel.text = "Stop Music"
		
		if checkSound() == true:
			pass
		else:
			exc.visible = true
			exc.rotate_y(deg_to_rad(90))
			$CharacterBody3D.on_c_pressed()
		
func _on_VolumeUpButton_pressed():
	#if is_playing:  # Adjust volume only if audio is playing
	audio.volume_db += volume_step
	soundSignifierLabel.text = str (audio.volume_db)
	
	if audio.volume_db > 24:  # Optionally cap the volume to 0 dB
		audio.volume_db = 24
	
	if checkSound() == true:
		exc.visible = false
		print("Sound is good now!")
		$CharacterBody3D.on_l_pressed()


func _on_VolumeDownButton_pressed():
	#if is_playing:  # Adjust volume only if audio is playing
	audio.volume_db -= volume_step
	soundSignifierLabel.text = str (audio.volume_db)
	
	if audio.volume_db < -40:  # Optionally cap the minimum volume to -40 dB
		audio.volume_db = -40
	if checkSound() == true:
		exc.visible = false
		print("Sound is good now!")
		$CharacterBody3D.on_l_pressed()
			
func _on_LightUpButton_pressed():
	light.light_energy += intensity_step
	var trimmedValue: String = "%0.2f" % light.light_energy
	lightSingnifierLabel.text = str(trimmedValue)
	#lightSingnifierLabel.text = str(light.light_energy)
	if checkLight() == true:
		pass
	else:
		pass
		#exc.visible = true
		#exc.rotate_y(deg_to_rad(90))
		#$CharacterBody3D.on_c_pressed()
		

func _on_LightDownButton_pressed():
	light.light_energy -= intensity_step
	var trimmedValue: String = "%0.2f" % light.light_energy
	lightSingnifierLabel.text = str(trimmedValue)
	#lightSingnifierLabel.text = str(light.light_energy)
	if checkLight() == true:
		pass
	else:
		pass
		#exc.visible = true
		#exc.rotate_y(deg_to_rad(90))
		#$CharacterBody3D.on_c_pressed()
	
	
func checkTemp():
	if roomTemp > 120:
		roomTemp = 120
	if roomTemp < 35:
		roomTemp = 35
	tempReading.text = str(roomTemp) + "°F"
	if roomTemp > 70:
		temp.texture_normal = preload("res://thermo_hot.png")
	elif roomTemp <= 70 and roomTemp > 50:
		temp.texture_normal = preload("res://thermo_good.png")
	elif roomTemp < 50:
		temp.texture_normal = preload("res://thermo_cold.png")
	
func _on_TempUpButton_pressed():
	roomTemp += 5

func _on_TempDownButton_pressed():
	roomTemp -= 5

func toggle_camera():
	# Deactivate the current camera
	cameras[current_camera_index].current = false
	if current_camera_index == 0:
		current_camera_index = 1
	else:
		current_camera_index = 0
	# Activate the new current camera
	cameras[current_camera_index].current = true
	print("Switched to: ", cameras[current_camera_index].name)
	if cameras[current_camera_index].name == "Camera3D2":
		$BlenderPopup.popup_centered()
	else:
		$BlenderPopup.hide()
		
func onKey3Pressed() -> void:
	if $Camera3DSpeaker.current == false:
			$Camera3DSpeaker.current = true
			soundWindow.popup()
			lightWindow.popup()
			tempWindow.popup()
	else:
		$Camera3DSpeaker.current = false
		soundWindow.hide()
		lightWindow.hide()
		tempWindow.hide()

func checkSound() -> bool:
	#print("Inside checkSound")
	var soundIsOk = false
	if  audio.volume_db < -10:
		soundSignifierLabel.modulate  = Color(0, 1, 0)
		soundIsOk = true
	else:
		soundIsOk = false
		soundSignifierLabel.modulate  = Color(1, 0, 0)
	return soundIsOk
	
func checkLight() -> bool:
	
	var lightIsOk = false
	if  light.light_energy < 1:
		var green_texture:Texture2D  = preload("res://green_light.png")
		lightPlayButton.texture_normal = green_texture
		lightSingnifierLabel.modulate  = Color(0, 1, 0)
		lightIsOk = true
	else:
		var yellow_texture:Texture2D = preload("res://light.png") as Texture2D
		lightPlayButton.texture_normal = yellow_texture
		lightIsOk = false
		lightSingnifierLabel.modulate  = Color(1, 0, 0)
	return lightIsOk
		
		
	
