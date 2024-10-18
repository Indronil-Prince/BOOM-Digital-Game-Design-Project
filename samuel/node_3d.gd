extends Node3D

func _ready():
	# Ensure the entire scene is visible
	self.show()
	# Optionally, ensure all children are also visible
	set_children_visibility(self, true)

func set_children_visibility(node, visibility):
	for child in node.get_children():
		if child is MeshInstance3D:
			child.visible = visibility
		set_children_visibility(child, visibility)
