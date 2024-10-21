extends Window

var label_node :Label
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	label_node = $Label1
	label_node.add_theme_color_override("font_color", Color(1, 0.5, 0))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
