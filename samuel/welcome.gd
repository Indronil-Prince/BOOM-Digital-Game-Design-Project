extends Window

var welcome: Window
var tasklist: Window
var samuelButton: Button
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _on_button_pressed() -> void:
	_on_close_requested()
	tasklist = get_node("/root/Node3D/Camera3D/TaskWindow")
	tasklist.visible = true
	samuelButton = get_node("/root/Node3D/CharacterBody3D/SamuelPopup/VBoxContainer/Button")
	samuelButton.visible = true
	

func _on_close_requested() -> void:
	welcome = $"."
	welcome.hide() # Replace with function body.
