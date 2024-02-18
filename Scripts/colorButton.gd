extends Button

var colorPicker
var manager
var currentColor

func setColor(color : Color):
	var box = (self.get_theme_stylebox("normal") as StyleBoxFlat)
	box.bg_color = color
	self.add_theme_stylebox_override("normal", box)
	self.add_theme_stylebox_override("hover", box)
	self.add_theme_stylebox_override("pressed", box)
	self.add_theme_stylebox_override("disabled", box)
	self.add_theme_stylebox_override("focus", box)
	pass

func _pressed():
	var wasVisible = colorPicker.visible
	manager.disableAll()
	colorPicker.visible = !wasVisible
	pass
	
func _ready():
	colorPicker = get_node("../../../ColorPicker")
	manager = get_node("../../../../../")
	setColor(colorPicker.color)
