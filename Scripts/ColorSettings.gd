extends VBoxContainer

var colorPickers = []

# Called when the node enters the scene tree for the first time.
func _ready():
	addColorPickers(self)
	disableAll()
	pass # Replace with function body.

func addColorPickers(node : Node):
	for nextNode in node.get_children():
		if(nextNode is ColorPicker):
			colorPickers.append(nextNode)
		addColorPickers(nextNode)
	pass

func visibility_changed():
	disableAll()
	pass

func disableAll():
	for colorPicker in colorPickers:
		colorPicker.visible = false
	pass
