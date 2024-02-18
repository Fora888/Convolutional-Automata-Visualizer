extends Button

@export var uiElement : Control


func _on_toggled(toggled_on):
	uiElement.visible = toggled_on
	pass # Replace with function body.
