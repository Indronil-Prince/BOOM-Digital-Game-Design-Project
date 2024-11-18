#extends Control
#
#
## Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	#pass # Replace with function body.
#
#
## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass

extends Control

# Function to skip and go to the game
func _on_SkipButton_pressed():
	get_tree().change_scene_to_file("res://node_3d.tscn")
