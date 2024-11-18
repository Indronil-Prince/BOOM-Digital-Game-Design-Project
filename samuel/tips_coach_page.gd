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

# Array to store all task labels
var tasks = []
var current_task_index = 0

func _ready():
	# Populate the tasks array with references to each task label
	tasks = [
		$"Task1",
		$"Task2",
		$"Task3",
		$"Task4",
		$"Task5",
		$"Task6",
		$"Task7"
		]
		
	# Show only the first task initially
	update_task_display()

# Function to return to the Home Screen
func _on_BackToHomeButton_pressed():
	get_tree().change_scene_to_file("res://start-scene.tscn")

# Function to update the task display
func update_task_display():
	# Hide all tasks
	for task in tasks:
		task.visible = false
	
	# Show the current task
	tasks[current_task_index].visible = true
	
	# Update button visibility
	$"NextButton".visible = current_task_index < tasks.size() - 1
	$"PreviousButton".visible = current_task_index > 0

# Function to handle Next button press
func _on_NextButton_pressed():
	if current_task_index < tasks.size() - 1:
		current_task_index += 1
		update_task_display()

# Function to handle Previous button press
func _on_PreviousButton_pressed():
	if current_task_index > 0:
		current_task_index -= 1
		update_task_display()
