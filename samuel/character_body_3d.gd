extends CharacterBody3D

@export var speed: float = 2.0  # Movement speed

@onready var living_room_position = $LivingRoomPosition.global_transform.origin
@onready var kitchen_position = $KitchenPosition.global_transform.origin
@onready var blender_position = $BlenderPosition.global_transform.origin  # New BlenderPosition

@onready var animation_player = $Happy_Walk/Walking_Animation

var current_target = Vector3()  # Current target position
var moving_to_target = true  # To control whether the character is moving
var target_stage = 0  # Track which target we are moving towards (0 for living room, 1 for kitchen, 2 for blender)
var turning = false  # Track whether the character is currently turning

func _ready():
	# Start moving towards the first target, LivingRoomPosition
	current_target = living_room_position
	start_walking_animation()

func _process(delta: float) -> void:
	if moving_to_target and not turning:
		# Calculate direction towards the target position
		var direction = (current_target - global_transform.origin).normalized()
		var distance = global_transform.origin.distance_to(current_target)

		# Move towards the target if far enough
		if distance > 0.1:
			# Calculate movement velocity vector
			var velocity = direction * speed * delta
			move_and_collide(velocity)
		else:
			# Stop the movement when the target is reached
			moving_to_target = false
			stop_walking_animation()
			print("Target reached.")
			
			# Handle movement to the next stage
			if target_stage == 0:
				# Reached LivingRoomPosition, now turn to move to KitchenPosition
				target_stage += 1
				turn_and_move_to_next_target(kitchen_position)
			elif target_stage == 1:
				# Reached KitchenPosition, now turn to move to BlenderPosition
				target_stage += 1
				turn_and_move_to_next_target(blender_position)

func turn_and_move_to_next_target(next_target: Vector3) -> void:
	# Simulate turning with a delay, then move to the next target
	turning = true
	await get_tree().create_timer(1.0).timeout  # Add a delay to simulate turning
	turn_character_left()
	# After turning, set the next target and start moving
	current_target = next_target
	moving_to_target = true
	turning = false
	start_walking_animation()

func turn_character_left() -> void:
	# Rotate character to the left (90 degrees) to simulate turning
	var current_rotation = rotation
	current_rotation.y -= deg_to_rad(90)  # Turn left by 90 degrees in radians
	rotation = current_rotation

func start_walking_animation() -> void:
	if animation_player != null and !animation_player.is_playing():
		animation_player.play("mixamo_com")

func stop_walking_animation() -> void:
	if animation_player != null and animation_player.is_playing():
		animation_player.stop()
