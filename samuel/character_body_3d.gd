extends CharacterBody3D

@export var speed: float = 5.0  # Movement speed

@onready var living_room_position = $LivingRoomPosition.global_transform.origin
@onready var kitchen_position = $KitchenPosition.global_transform.origin
@onready var blender_position = $BlenderPosition.global_transform.origin  # New BlenderPosition
@onready var bedroom_position = $BedRoomPosition.global_transform.origin  # Bedroom position
@onready var animation_player = $Happy_Walk/Walking_Animation
@onready var exclamation_sprite = $ExclamationSprite  # Reference to the exclamation sprite

var moveSamuelButton : Button
var moveSamuelPopup : Popup
var instructionCounter = 0
var taskWindowLabel : Label
var taskWindowPoint : Label
var kitechenAudio : AudioStreamPlayer3D

var current_target = Vector3()  # Current target position
var moving_to_target = false  # To control whether the character is moving
var target_stage = 0  # Track which target we are moving towards (0 for living room, 1 for kitchen, 2 for blender)
var turning = false  # Track whether the character is currently turning
var returning = false  # Flag to check if character is returning after blender is on
var direct_move = false  # Flag to check if we are directly moving to a target without sequence

func _ready():
	# Set the first target but don't start moving automatically
	current_target = living_room_position

	# Reference the popup and button
	moveSamuelPopup = $SamuelPopup
	moveSamuelButton = $SamuelPopup/VBoxContainer/Button
	taskWindowLabel = get_node("/root/Node3D/Camera3D/TaskWindow/Label2")
	taskWindowPoint = get_node("/root/Node3D/Camera3D/TaskWindow/Point")

	# Connect the blender's "blender_turned_on" signal from BlenderPopup
	var blender_node = get_node("/root/Node3D/BlenderPopup")  # Adjusted path to BlenderPopup
	blender_node.connect("blender_turned_on", Callable(self, "_on_blender_turned_on"))
	kitechenAudio = get_node("/root/Node3D/kitchen/AudioStreamKitchen")

func _process(delta: float) -> void:
#func _process(delta: float) -> void:
	if Input.is_key_pressed(KEY_B):
		on_b_pressed()
	elif Input.is_key_pressed(KEY_L):
		on_l_pressed()
	elif Input.is_key_pressed(KEY_C):
		on_c_pressed()

	moveSamuelPopup.popup()
	moveSamuelButton.text = "Say: Move to the kitchen"

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

func stop_exclamation() -> void:
	if exclamation_sprite:
		exclamation_sprite.visible = false

func _on_button_pressed() -> void:
	instructionCounter += 1
	moveSamuelButton.text += " x:" + str(instructionCounter)

	if instructionCounter >= 3:
		moveSamuelButton.hide()
		$SamuelPopup/VBoxContainer.hide()
		$SamuelPopup.hide()
		moving_to_target = false
