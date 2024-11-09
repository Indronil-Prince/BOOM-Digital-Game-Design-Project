extends TextureButton

var Tex: TextureRect
var TexButton: TextureButton
var timer: Timer
var panel2
 
func _ready():
	# Initialize TextureRect
	Tex = get_node("/root/Node2D/Control/TextureRect")
	# Setup a timer
	timer = Timer.new()
	timer.wait_time = 10  # Set timer to wait for 5 seconds
	timer.one_shot = true  # The timer will stop after triggering once
	add_child(timer)
	timer.connect("timeout", Callable(self, "_on_Timer_timeout"))  # Connect timeout signal to a function

func _process(delta) -> void:
	#panel2.visible = true
	pass
	
func _on_Button_pressed():
	Tex.texture = load("res://splash-screen1.png")  
	# Load and show the image
	timer.start()  # Start the timer
	TexButton = get_node("/root/Node2D/Control/TextureButton")
	TexButton.visible = false

func _on_Timer_timeout():
	get_tree().change_scene_to_file("res://node_3d.tscn")
	#panel2.visible = true
	
