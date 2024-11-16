extends Control  # Adjust to the base node type if needed

# Target positions and duration
var target_y := 550  # Set the destination y position (y2)
var initial_y := 0  # Starting y position (y1)
var duration := 2.0  # Duration for moving up and down
var stay_duration := 10.0
 
# Movement variables
var velocity: float = 0.0  # Movement speed (calculated)
var moving_up: bool = true  # Whether we're moving up or down

# Typing animation variables
var full_text := "This is the typing animation for the text in the panel."
var display_text := ""  # Text currently displayed in the RichTextLabel
var char_index := 0     # Current character index
var typing_speed := 0.05  # Time interval between each character (seconds)
var typing_timer  # Reference to the dynamically created typing timer

# Node references
@onready var text_label = $CenterContainer/RichTextLabel
@onready var move_up_timer = $MoveUpTimer
@onready var stay_timer = $StayTimer
@onready var move_down_timer = $MoveDownTimer
@onready var panel = get_node("/root/Node3D/Dialog/Panel2")

func _ready():
	# Set the initial position
	initial_y = position.y
	target_y += 325
	
	position.y = initial_y  # Ensure starting position

	# Connect timers programmatically using Callable
	move_up_timer.connect("timeout", Callable(self, "_on_MoveUpTimer_timeout"))
	stay_timer.connect("timeout", Callable(self, "_on_StayTimer_timeout"))
	move_down_timer.connect("timeout", Callable(self, "_on_MoveDownTimer_timeout"))


# Typing Animation Functions
func start_typing_animation():
	# Create a new typing timer and store a reference to it
	typing_timer = Timer.new()
	typing_timer.wait_time = typing_speed
	typing_timer.one_shot = false
	typing_timer.connect("timeout", Callable(self, "_on_typing_timer_timeout"))
	add_child(typing_timer)
	typing_timer.start()
	
func _process(delta):
	# Smooth movement while MoveUpTimer is active
	if move_up_timer.time_left > 0:
		var t = (duration - move_up_timer.time_left) / duration
		position.y = lerp(initial_y, target_y, t)
	
	# Smooth movement while MoveDownTimer is active
	elif move_down_timer.time_left > 0:
		var t = (duration - move_down_timer.time_left) / duration
		position.y = lerp(target_y, initial_y, t)
		
	if Input.is_key_pressed(KEY_Q):
		startCoach("Show me this text. You pressed Q button")
		
		

func _on_MoveUpTimer_timeout():
	print("Move Up Timer Finished, starting Stay Timer")  # Debug print
	# Ensure position reaches target exactly and start the StayTimer
	position.y = target_y
	stay_timer.start()  # Start the stay period
	start_typing_animation()  # Start typing effect during upward movement

func _on_StayTimer_timeout():
	print("Stay Timer Finished, starting Move Down Timer")  # Debug print
	# After the stay period, start MoveDownTimer to move back down
	move_down_timer.start()

func _on_MoveDownTimer_timeout():
	print("Move Down Timer Finished")  # Debug print
	# Ensure the panel is back to the initial position after moving down
	position.y = initial_y

func _on_typing_timer_timeout():
	if char_index < full_text.length():
		# Add the next character to the display text
		display_text += full_text[char_index]
		text_label.text = display_text  # Update the RichTextLabel's text
		char_index += 1
	else:
		# Stop the typing animation once the full text is displayed
		typing_timer.stop()
		typing_timer.queue_free()  # Remove the timer after completion

func startCoach(content: String) -> void :
	# Start moving up
	#full_text = ""
	#full_text = content
	#print("Starting Move Up Timer")  # Debug print
	#move_up_timer.start()
	#panel.visible = true
	full_text = content               # Set the new content for the text display
	text_label.text = full_text       # Directly display the full text without animation
	
	# Optionally clear any timers if they were previously used
	if typing_timer !=null and typing_timer and typing_timer.is_inside_tree():
		typing_timer.stop()
		typing_timer.queue_free()
		typing_timer = null
	
	# Start the upward movement and make panel visible
	move_up_timer.start()
	panel.visible = true
