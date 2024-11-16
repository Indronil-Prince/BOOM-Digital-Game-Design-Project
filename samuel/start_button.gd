extends TextureButton

var Tex: TextureRect
var startGameButton: TextureButton
var tipsButton: TextureButton
var objectiveButton: TextureButton
var creditButton: TextureButton
var settingsButton: TextureButton
var moreButton: TextureButton
var timer: Timer
#var panel2
 
func _ready():
	# Initialize TextureRect
	Tex = get_node("/root/Node2D/Control/TextureRect")
	# Setup a timer
	timer = Timer.new()
	timer.wait_time = 2  # Set timer to wait for 5 seconds
	timer.one_shot = true  # The timer will stop after triggering once
	add_child(timer)
	timer.connect("timeout", Callable(self, "_on_Timer_timeout"))  # Connect timeout signal to a function

func _process(delta) -> void:
	#panel2.visible = true
	startGameButton = $"."
	tipsButton =$"../tipsButton"
	objectiveButton = $"../objectiveButton"
	creditButton = $"../creditButton"
	settingsButton = $"../settingsButton"
	moreButton =$"../moreButton"
	
func _on_Button_pressed():
	Tex.texture = load("res://splash-screen1.png")  
	# Load and show the image
	timer.start()  # Start the timer
	#startGameButton = get_node("/root/Node2D/Control/startGameButton")
	startGameButton.visible = false
	tipsButton.visible = false
	objectiveButton.visible = false
	creditButton.visible = false
	settingsButton.visible = false
	moreButton.visible = false

func _on_Timer_timeout():
	get_tree().change_scene_to_file("res://node_3d.tscn")
	#panel2.visible = true
	
