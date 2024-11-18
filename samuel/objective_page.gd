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

# Function to go back to the start scene
func _on_BackToHomeButton_pressed():
	get_tree().change_scene_to_file("res://start-scene.tscn")
