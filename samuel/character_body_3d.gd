extends CharacterBody3D

@export var speed: float = 5.0  # Movement speed

@onready var living_room_position = $LivingRoomPosition.global_transform.origin
@onready var kitchen_position = $KitchenPosition.global_transform.origin
@onready var blender_position = $BlenderPosition.global_transform.origin  # New BlenderPosition
@onready var bedroom_position = $BedRoomPosition.global_transform.origin  # Bedroom position
@onready var animation_player = $Happy_Walk/Walking_Animation
@onready var exclamation_sprite = $ExclamationSprite  # Reference to the exclamation sprite
@onready var exclamAnimPlayer = $ExclamationSprite/ExclamationAnimationPlayer

@onready var position_a = $PositionA.global_transform.origin  # Position A
@onready var position_b = $PositionB.global_transform.origin  # Position B
@onready var position_c = $PositionC.global_transform.origin  # Position C
@onready var position_d = $PositionD.global_transform.origin  # Position D
@onready var position_e = $PositionE.global_transform.origin  # Position E
@onready var position_f = $PositionF.global_transform.origin  # Position F
@onready var position_g = $PositionG.global_transform.origin  # Position G

@onready var fridge_position = $FridgePosition.global_transform.origin

var t_sequence_active = false  # To track if the T sequence is active
var t_sequence_stage = 0  # To track the stage of the sequence (A -> B -> C -> Bedroom)

const  TIME_THRESHOLD = 20

var moveSamuelButton : Button
var moveSamuelPopup : Popup
var instructionCounter = 0
var taskWindowLabel : Label
var taskWindowPoint : Label
var goToLivingRoomAudio : AudioStreamPlayer3D
var pointLabel: Label
var gameTimerLabel: Label
var dialogAudioPlayer: AudioStreamPlayer3D
var panel2: Panel
var panelChar: Sprite2D
var node3D: Node3D

var task1Label: Label
var task2Label: Label
var task3Label: Label
var task4Label: Label
var task5Label: Label
var task6Label: Label
var task7Label: Label

var target_string: String
var sayHelloTask: bool
var moveToLivingRoomTask: bool
var adjustLightMusicTempTask: bool
var moveToKitchenTask: bool
var blenderTask: bool
var vaccuamCleanTask: bool
var foodTask: bool
var time: String
var countdown_time = 6 * 60
var first_click_time = -1

var current_target = Vector3()  # Current target position
var moving_to_target = false  # To control whether the character is moving
var target_stage = 0  # Track which target we are moving towards (0 for living room, 1 for kitchen, 2 for blender)
var turning = false  # Track whether the character is currently turning
var returning = false  # Flag to check if character is returning after blender is on
var direct_move = false  # Flag to check if we are directly moving to a target without sequence
var blender_node
func _ready():
	sayHelloTask = false
	moveToLivingRoomTask = false
	adjustLightMusicTempTask = false
	blenderTask = false
	vaccuamCleanTask = false
	foodTask = false 	
	moveToKitchenTask = false
	# Start moving towards the first target, LivingRoomPosition
	current_target = living_room_position
	# Stop Samuel from walking automatically with game start
	moving_to_target = false

	# Reference the popup and button
	moveSamuelPopup = $SamuelPopup
	moveSamuelButton = $SamuelPopup/VBoxContainer/Button
	taskWindowLabel = get_node("/root/Node3D/Camera3D/TaskWindow/Label2")
	taskWindowPoint = get_node("/root/Node3D/Camera3D/TaskWindow/Point")

	# Connect the blender's "blender_turned_on" signal from BlenderPopup
	blender_node = get_node("/root/Node3D/BlenderPopup")  # Adjusted path to BlenderPopup
	blender_node.connect("blender_turned_on", Callable(self, "_on_blender_turned_on"))
	goToLivingRoomAudio = get_node("/root/Node3D/kitchen/AudioStreamKitchen")
	
	node3D = $".."
	node3D.connect("vacuum_turned_on", Callable(self, "_on_vacuum_turned_on"))
	goToLivingRoomAudio = get_node("/root/Node3D/kitchen/AudioStreamKitchen")
	
	
	pointLabel = $"../Camera3D/TaskWindow/Point"
	gameTimerLabel = $"../Camera3D/TaskWindow/GameTimer"
	dialogAudioPlayer = $"../Camera3D/TaskWindow/dialogAudioPlayer"
	panel2 = $"../Dialog/Panel2"
	panelChar = $"../Dialog/Panel2/SamuelPopUp"
	
	task1Label = $"../Camera3D/TaskWindow/Label1"
	task2Label = $"../Camera3D/TaskWindow/Label2"
	task3Label = $"../Camera3D/TaskWindow/Label3"
	task4Label = $"../Camera3D/TaskWindow/Label4"
	task5Label = $"../Camera3D/TaskWindow/Label5"
	task6Label = $"../Camera3D/TaskWindow/Label6"
	task7Label = $"../Camera3D/TaskWindow/Label7"
	
	node3D = $".."
	
func _process(delta: float) -> void:
#func _process(delta: float) -> void:
	if Input.is_key_pressed(KEY_B):
		on_b_pressed()
	elif Input.is_key_pressed(KEY_L):
		on_l_pressed()
	elif Input.is_key_pressed(KEY_C):
		on_c_pressed()
	elif Input.is_key_pressed(KEY_T):
		on_t_pressed()  # Start the sequence for T key
	elif Input.is_key_pressed(KEY_F):
		on_f_pressed()
	
	moveSamuelPopup.popup()
	handleTimer(delta)
	
	if sayHelloTask == false:
		target_string = "Say: Hello Samuel!"
		moveSamuelButton.text = target_string
		moveSamuelButton.text += " x:" + str(instructionCounter)
	elif sayHelloTask == true && moveToLivingRoomTask == false:
		#print ("inside elif condition")
		target_string = "Say: Go to Living Room"
		moveSamuelButton.text = target_string
		moveSamuelButton.text += " x:" + str(instructionCounter)
	elif sayHelloTask == true && moveToLivingRoomTask == true &&	adjustLightMusicTempTask == true:
		target_string = "Say: Go to Kitchen"
		moveSamuelButton.text = target_string
		moveSamuelButton.text += " x:" + str(instructionCounter)
		moveSamuelButton.show()
		$SamuelPopup/VBoxContainer.show()
		$SamuelPopup.show()
	elif sayHelloTask == true && moveToLivingRoomTask == true &&	adjustLightMusicTempTask == true && moveToKitchenTask == true:
		print("Checking on Blender Task")
		if blender_node.notifySamuelForBlender == true:
			task5Label.add_theme_color_override("font_color", Color(1, 0.5, 0))
			popupCoach("Task 5 completed! You've earned +200 Points! Please pick some food for Samuel as task#6")
			task5Label.text += " +200 Points"
			$"../kitchen/MeshInstance3D/BlenderTable/PlasticCup12".visible = true
		elif blender_node.notifySamuelForBlender == false:
			#on_c_pressed()
			#_on_blender_turned_on()
			#show_exclamation() 
			returning = true
			target_stage = 1
			show_exclamation()
			speed = 4.0
			$BedRoomPosition
			

	# Main movement logic
	if moving_to_target and not turning:
		var direction = (current_target - global_transform.origin).normalized()
		var distance = global_transform.origin.distance_to(current_target)

		if distance > 0.1:
			var velocity = direction * speed * delta
			move_and_collide(velocity)
		else:
			moving_to_target = false
			stop_walking_animation()
			print("Target reached.")
		
		#If sequence is active, move to the next position in the sequence
			if t_sequence_active:
				continue_t_sequence()  # Call `on_t_pressed` again to set the next target	

			if direct_move:
				# Custom sequence steps for direct move mode
				if current_target == kitchen_position and target_stage == 0:
					print("Reached Kitchen - Now heading to Living Room")
					target_stage += 1
					turn_and_move_to_next_target(living_room_position)
				elif current_target == living_room_position and target_stage == 1:
					print("Reached Living Room - Now heading to Bedroom")
					target_stage += 1
					turn_and_move_to_next_target(bedroom_position)
				elif current_target == bedroom_position and target_stage == 2:
					print("Reached Bedroom - Custom path complete.")
					direct_move = false  # End custom path here

			elif not returning:
				# Handle main sequence stages
				if target_stage == 0:
					target_stage += 1
					turn_and_move_to_next_target(kitchen_position)
				elif target_stage == 1:
					target_stage += 1
					turn_and_move_to_next_target(blender_position)
					taskWindowLabel.add_theme_color_override("font_color", Color(1, 0.5, 0))
					taskWindowPoint.text = "50"

			elif returning:
				if target_stage == 1:
					target_stage += 1
					turn_and_move_to_next_target(living_room_position)
				elif target_stage == 2:
					target_stage += 1
					turn_and_move_to_next_target(bedroom_position)
				elif target_stage == 3:
					print("Return sequence complete.")
					stop_exclamation()

# Function for B key press
func on_b_pressed() -> void:
	print("Pressed B Button - Starting Sequence from Living Room")
	moving_to_target = true
	target_stage = 0  # Reset to start the sequence from the beginning
	current_target = living_room_position  # Start sequence from Living Room
	direct_move = false
	returning = false  # Ensure forward sequence
	face_target(current_target)
	start_walking_animation()

# Function for L key press
func on_l_pressed() -> void:
	print("Pressed L Button - Moving to Living Room")
	direct_move = true

	# If character is in the bedroom, go directly to living room
	if global_transform.origin.distance_to(bedroom_position) < 0.1:
		current_target = living_room_position
		moving_to_target = true
		face_target(current_target)
		start_walking_animation()

	# If character is at the blender position, go to kitchen first, then living room
	elif global_transform.origin.distance_to(blender_position) < 0.1:
		print("Character at Blender - Moving to Kitchen, then Living Room")
		target_stage = 0
		turn_and_move_to_next_target(kitchen_position)

	# Otherwise, go directly to the living room
	else:
		current_target = living_room_position
		moving_to_target = true
		face_target(current_target)
		start_walking_animation()

# Function for C key press
func on_c_pressed() -> void:
	print("Pressed C Button - Custom Path Based on Current Position")
	direct_move = true

	if global_transform.origin.distance_to(living_room_position) < 0.1:
		# Case 1: If character is in Living Room, move directly to Bedroom
		current_target = bedroom_position
		moving_to_target = true
		face_target(current_target)
		start_walking_animation()

	elif global_transform.origin.distance_to(blender_position) < 0.1:
		# Case 2: If character is in Blender Position, go through sequence Kitchen -> Living Room -> Bedroom
		target_stage = 0  # Start custom sequence from Kitchen
		turn_and_move_to_next_target(kitchen_position)

func _on_blender_turned_on() -> void:
	if sayHelloTask == true && moveToLivingRoomTask == true &&	adjustLightMusicTempTask == true && moveToKitchenTask == true:
		if blender_node.notifySamuelForBlender == true:
			task5Label.add_theme_color_override("font_color", Color(1, 0.5, 0))
			popupCoach("Task 5 completed! You've earned +200 Points! Please vacuum clean the kitchen as a task#6")
			task5Label.text += " +200 Points"
			blenderTask = true
			on_f_pressed()
			node3D.toggle_camera()
		elif blender_node.notifySamuelForBlender == false:
			returning = true
			target_stage = 1
			show_exclamation()
			speed = 4.0
			$BedRoomPosition
			face_target(kitchen_position)
			current_target = kitchen_position
			moving_to_target = true
			start_walking_animation()

func face_target(target_position: Vector3) -> void:
	var direction = (target_position - global_transform.origin).normalized()
	var target_rotation = Vector3()
	target_rotation.y = atan2(direction.x, direction.z)
	rotation = target_rotation

func turn_and_move_to_next_target(next_target: Vector3) -> void:
	turning = true
	await get_tree().create_timer(1.0).timeout
	face_target(next_target)
	current_target = next_target
	moving_to_target = true
	turning = false
	start_walking_animation()

func start_walking_animation() -> void:
	if animation_player != null and !animation_player.is_playing():
		animation_player.play("mixamo_com")

func stop_walking_animation() -> void:
	if animation_player != null and animation_player.is_playing():
		animation_player.stop()

func show_exclamation() -> void:
	if exclamation_sprite:
		exclamation_sprite.visible = true
		exclamAnimPlayer.play("Exclamation_Left")
		
func stop_exclamation() -> void:
	if exclamation_sprite:
		exclamation_sprite.visible = false
		exclamAnimPlayer.stop()

func _on_button_pressed() -> void:
	processTasks()
	
func handleTimer(delta)-> void :
	if countdown_time > 0:
		countdown_time -= delta  # Subtract the delta time from the countdown
		var minutes = int(countdown_time) / 60
		var seconds = int(countdown_time) % 60
		#gameTimerLabel.text = ""
		pointLabel.text = str("%0.2f" %countdown_time)
		gameTimerLabel.text = str(minutes).pad_zeros(2) + ":" + str(seconds).pad_zeros(2)  # Format as MM:SS
	else:
		gameTimerLabel.text = "00:00"  # Display when countdown reaches zero
		set_process(false)  # Stop updating once the countdown is over

func getElapsedTime()-> String :
	var elapsed_time = 0.0
	if instructionCounter%2 == 1:
		# This is the first click; record the time
		first_click_time = Time.get_ticks_msec()
		print("First button click recorded.")
	else:
		# This is the second click; calculate the elapsed time
		var second_click_time = Time.get_ticks_msec()
		elapsed_time = (second_click_time - first_click_time) / 1000.0  
		print("Time elapsed between clicks: ", elapsed_time, " seconds")	
	return str(elapsed_time)
		
func popupCoach(dialog: String)-> void :
	print("coach popup is called")
	#panel2.full_text = "You need to speak 3 times. And each sentence should have a 2 sec gap in between so that Samuel can understand!!"
	#panel2.startCoach("One need to repeat the sentence three times face to face to Samuel and each sentence should have a 2 seconds gap in between so that Samuel can understand!!")
	panel2.startCoach(dialog)
	var new_texture = load("res://coach.png")
	panelChar.texture = new_texture

func popupSamuel(dialog: String)-> void:
	print("Samuel popup is called")	
	#panel2.full_text = "Hello there!!!"
	#panel2.startCoach("Hello there!!!")
	panel2.startCoach(dialog)
	var new_texture = load("res://SamuelPopUp.jpg")
	panelChar.texture = new_texture	
	
func processTasks()-> void:
	instructionCounter+=1
	#target_string = "Say: Hello Samuel!"
	if target_string in "Say: Hello Samuel!" :
		dialogAudioPlayer.play()
		time = getElapsedTime()
		print("elasped time: ", time , "Secs")
		if(time.to_float() > 0.0 && time.to_float() <=2.0):
			popupCoach("One need to repeat the sentence three times face to face to Samuel and each sentence should have a 2 seconds gap in between so that Samuel can understand!!")
			instructionCounter = instructionCounter- 1
		if instructionCounter >=3:
			print ("Hello Samuel Said by the user")
			
			instructionCounter = 0;
			moveSamuelButton.text = ""
			sayHelloTask = true
			time = ""
			task1Label.add_theme_color_override("font_color", Color(1, 0.5, 0))
			#popupSamuel("Hello There!!")
			popupCoach("Task 1 is completed! Samuel replied back 'Hello There!'. You've earned +200 Points! Please ask Samuel to move to the living room as a task#2.")
			task1Label.text += " +200 Points"
			
	
	elif  target_string in "Say: Go to Living Room":
		first_click_time == -1
		goToLivingRoomAudio.play()
		time = getElapsedTime()
		print("elasped time: ", time , "Secs")
		if(time.to_float() > 0.0 && time.to_float() <=2.0):
			popupCoach("One need to repeat the sentence three times face to face to Samuel and each sentence should have a 2 seconds gap in between so that Samuel can understand!!")
			instructionCounter = instructionCounter -1
		if instructionCounter >=3:
			#print("button pressed elif")
			goToLivingRoomAudio.play()
			moveToLivingRoomTask = true
			moveSamuelButton.hide()
			$SamuelPopup/VBoxContainer.hide()
			$SamuelPopup.hide()
			instructionCounter = 0;
			time = ""
			moveToLivingRoomTask =true
			moving_to_target = true
			on_l_pressed()
			task2Label.add_theme_color_override("font_color", Color(1, 0.5, 0))
			popupCoach("Task 2 completed! You've earned +200 Points! Please set up light intesity, soothing room temperatue and suitable music for Samuel as a task#3 in 30 seconds")
			task2Label.text += " +200 Points"
			node3D.onKey3Pressed()
			startTask3Timer()
	
	elif  target_string in "Say: Go to Kitchen":
		first_click_time == -1
		var new_audio = load("res://go-to-kitchen.mp3") as AudioStream
		goToLivingRoomAudio.stream = new_audio
		goToLivingRoomAudio.play()
		time = getElapsedTime()
		print("elasped time: ", time , "Secs")
		if(time.to_float() > 0.0 && time.to_float() <=2.0):
			popupCoach("One need to repeat the sentence three times face to face to Samuel and each sentence should have a 2 seconds gap in between so that Samuel can understand!!")
			instructionCounter = instructionCounter -1
		if instructionCounter >=3:
			#print("button pressed elif")
			goToLivingRoomAudio.play()
			moveToKitchenTask = true
			moveSamuelButton.hide()
			$SamuelPopup/VBoxContainer.hide()
			$SamuelPopup.hide()
			instructionCounter = 0;
			time = ""
			moving_to_target = true
			on_b_pressed()
			task4Label.add_theme_color_override("font_color", Color(1, 0.5, 0))
			popupCoach("Task 4 completed! You've earned +200 Points! Please prepare a glass of juice using the blender as a task#5")
			task4Label.text += " +200 Points"
			node3D.toggle_camera()
			#node3D.onKey3Pressed()
			#startTask3Timer()	
			
func startTask3Timer() ->void:
	var timer = Timer.new()
	timer.wait_time = TIME_THRESHOLD  # Set the timer to 30 seconds
	timer.one_shot = true  # Ensure the timer triggers only once
	add_child(timer)  # Add the Timer node to the scene
	#timer.connect("timeout", self, "_on_task3_timer_timeout")  # Connect the timeout signal
	timer.connect("timeout", Callable(self, "_on_task3_timer_timeout"))
	timer.start()  # Start the timer	
	
func _on_task3_timer_timeout() -> void:
	print("_on_task3_timer_timeout")
	if node3D.checkTemperature() && node3D.checkLight()  and node3D.checkSound():
		popupCoach("Task3 is completed. +200 Points. Please move Samuel to the kitchen for Task#4")
		task3Label.text += " +200 Points"
		task3Label.add_theme_color_override("font_color", Color(1, 0.5, 0))
		adjustLightMusicTempTask = true
		#print("Task3 is completed")
	else:
		popupSamuel("I am struggling with temperature /light Intesity / Sound. Plase adjust! And I am moving back to my room")
		show_exclamation()
		on_c_pressed()

# Function for T key press


func on_t_pressed() -> void:
# Ensure the sequence is only activated if it's not already active
	if not t_sequence_active:
		print("Pressed T Button - Starting sequence from Bedroom to A -> B -> C -> D -> E -> F -> G -> Bedroom")
		t_sequence_active = true  # Activate the sequence
		# Start the sequence from Bedroom to Position A
		current_target = position_a
		moving_to_target = true
		face_target(current_target)
		start_walking_animation()
# Function to continue to the next target in the sequence

func continue_t_sequence() -> void:
	if not t_sequence_active:
		return  # Exit if sequence is no longer active
	# Check current position and set the next target accordingly
	if global_transform.origin.distance_to(position_a) < 0.1:
		current_target = position_b
	elif global_transform.origin.distance_to(position_b) < 0.1:
		current_target = position_c
	elif global_transform.origin.distance_to(position_c) < 0.1:
		current_target = position_d
	elif global_transform.origin.distance_to(position_d) < 0.1:
		current_target = position_e
	elif global_transform.origin.distance_to(position_e) < 0.1:
		current_target = position_f
	elif global_transform.origin.distance_to(position_f) < 0.1:
		current_target = position_g
	elif global_transform.origin.distance_to(position_g) < 0.1:
		# Final target: back to Bedroom
		current_target = bedroom_position
	else:
		# End sequence once back at the bedroom
		t_sequence_active = false
		print("Sequence complete. Returned to Bedroom.")
		return
	# Start movement and animation towards the next target
	moving_to_target = true
	face_target(current_target)
	start_walking_animation()

func on_f_pressed() -> void:
	print("Pressed F Button - Starting Sequence from Blender Position")
	moving_to_target = true
	target_stage = 0  # Reset to start the sequence from the beginning
	current_target = fridge_position  # Start sequence from Living Room
	direct_move = true
	returning = false  # Ensure forward sequence
	face_target(current_target)
	start_walking_animation()
	
func _on_vacuum_turned_on() -> void:
	#if sayHelloTask == true && moveToLivingRoomTask == true &&	adjustLightMusicTempTask == true && moveToKitchenTask == true:
	if node3D.notifySamuelforVacuum == true:
		task7Label.add_theme_color_override("font_color", Color(1, 0.5, 0))
		popupCoach("Task 7 completed! You've earned +200 Points! GAME OVER!! CONGRATULATIONS")
		task7Label.text += " +200 Points"
		vaccuamCleanTask = true
		
		#Game End Logic
		#moveSamuelButton.text = "Game Over! Congratulations!"
		#moveSamuelButton.disabled = true
		
	elif node3D.notifySamuelforVacuum == false:
		print("Condition entered!")
		moving_to_target = true
		face_target(blender_position)
		current_target = blender_position
		start_walking_animation()
		if global_transform.origin.distance_to(blender_position) < 0.1:
			on_c_pressed() ####Bedroom position not working


func _on_red_bowl_pressed() -> void:
	task6Label.add_theme_color_override("font_color", Color(1, 0.5, 0))
	popupCoach("You choose the correct bowl of Samuel's color code. Task 6 completed! You've earned +200 Points! Please vacuum clean the kitchen as a task#7")
	task6Label.text += " +200 Points"

func _on_blue_bowl_pressed() -> void:
	pass # Replace with function body.
