extends Control

func _on_visibility_changed():
	if !visible:
		pass
	var interpolator = 0.0
	
	while interpolator < 1:
		interpolator = min(interpolator + 0.01, 1)
		self.scale = Vector2(interpolator, interpolator)
		await get_tree().process_frame
		
	
	pass
