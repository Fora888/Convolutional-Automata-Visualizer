extends HSlider

var micInput

func _ready():
	micInput = get_node("/root/Node2D/AudioStreamPlayer")
	pass
	
func _on_value_changed(value):
	micInput.volume_db = value
	pass # Replace with function body.
