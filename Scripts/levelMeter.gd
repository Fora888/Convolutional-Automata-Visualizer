extends ProgressBar

func logWithBase(value, base): return log(value) / log(base)

var regularColor

func _ready():
	regularColor = (self.get_theme_stylebox("fill") as StyleBoxFlat).bg_color
	pass

func _process(delta):
	var levelLeft = AudioServer.get_bus_peak_volume_left_db(2,0)
	var levelRight = AudioServer.get_bus_peak_volume_right_db(2,0)
	var averageLevel = 20 * logWithBase( (pow(10, levelLeft / 20.0) + pow(10, levelRight / 20)) / 2, 10)
	averageLevel = max(averageLevel / 60.0 + 1.0,0.0)
	self.value = averageLevel
	
	var box = (self.get_theme_stylebox("fill") as StyleBoxFlat)
	if (averageLevel > 1):
		box.bg_color = Color.RED
	else:
		box.bg_color = regularColor
	self.add_theme_stylebox_override("fill", box)
	
	pass
