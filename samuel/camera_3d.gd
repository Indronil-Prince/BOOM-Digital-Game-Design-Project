extends Camera3D
 
# Speed at which the camera moves
var speed = 5.0
var rotation_speed = 1.0
 
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	make_current()
 
func _process(delta):
	var input_vector = Vector3.ZERO
	var pitch_change = 0.0
	# Check for right and left arrow keys
	if Input.is_key_pressed(KEY_RIGHT):
		input_vector.x += 1
	if Input.is_key_pressed(KEY_LEFT):
		input_vector.x -= 1
	if Input.is_key_pressed(KEY_EQUAL):
		input_vector.y += 1
	if Input.is_key_pressed(KEY_MINUS):
		input_vector.y -= 1
	# Check for up and down arrow keys for forward and backward movement
	if Input.is_key_pressed(KEY_UP):
		input_vector.z -= 1
		input_vector.y += 1
		pitch_change += rotation_speed
		#rotate_y(deg_to_rad(5))
	if Input.is_key_pressed(KEY_DOWN):
		input_vector.z += 1
		input_vector.y -= 1  # Positive z-direction is backward
		pitch_change -= rotation_speed
		#rotate_y(deg_to_rad(5))
	# Normalize the move vector to have consistent movement speed
	input_vector = input_vector.normalized() * speed * delta
 
	# Apply the translation in local coordinates
	translate_object_local(input_vector)
 
	## Apply the pitch change
	#if pitch_change != 0:
		#rotate_y(deg_to_rad(pitch_change * delta))
	if Input.is_key_pressed(KEY_R):
		rotate_y(deg_to_rad(180))
