extends Button

@export var uiElement : Control


func _on_toggled(toggled_on):
	uiElement.visible = toggled_on
	if toggled_on:
		self.text = "Info\n(Click to hide)"
	else:
		self.text = "Info"
	pass # Replace with function body.
