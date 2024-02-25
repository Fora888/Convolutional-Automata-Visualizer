extends Node2D
# Called when the node enters the scene tree for the first time.

@export var noiseMaterial : ShaderMaterial
@export var copyMaterial : ShaderMaterial
@export var randomRange : float = 1.0
@export var fullKernelGenerator : Node
@export var splitKernelGenerator : Node
@export var singleKernelGenerator : Node
var currentKernelGenerator
var bufferWindowRatio = 0.4
var rng = RandomNumberGenerator.new()
var saturate = false
var zoom = true

func toggleZoom(on : bool):
	zoom = on
	pass
	

func toggleFullscreen():
	var windowMode = DisplayServer.window_get_mode()
	if(windowMode == DisplayServer.WINDOW_MODE_FULLSCREEN):
		DisplayServer.window_set_mode ( DisplayServer.WINDOW_MODE_WINDOWED, 0)
	else:
		DisplayServer.window_set_mode ( DisplayServer.WINDOW_MODE_FULLSCREEN, 0)

func setSaturation(on : bool):
	currentKernelGenerator.setSaturation(on)
	saturate = on

func setFullKernelGenerator():
	currentKernelGenerator.setUI(false)
	currentKernelGenerator = fullKernelGenerator
	currentKernelGenerator.setUI(true)
	updatePostProcessing()
		
func setSplitKernelGenerator():
	currentKernelGenerator.setUI(false)
	currentKernelGenerator = splitKernelGenerator
	currentKernelGenerator.setUI(true)
	updatePostProcessing()
		
func setSingleKernelGenerator():
	currentKernelGenerator.setUI(false)
	currentKernelGenerator = singleKernelGenerator
	currentKernelGenerator.setUI(true)
	updatePostProcessing()
	
func updatePostProcessing():
	currentKernelGenerator.updatePostProcessing()
	currentKernelGenerator.setSaturation(saturate)

func randomizeKernel():
	currentKernelGenerator.randomizeWeights()
	pass

func resizeBuffers():
	var screenSize = get_tree().get_root().size
	$FrontBuffer.size = screenSize * bufferWindowRatio
	$BackBuffer.size = screenSize * bufferWindowRatio
	pass
	
func reset():
	$BackBuffer/TextureRect.material = noiseMaterial
	await RenderingServer.frame_post_draw
	$BackBuffer/TextureRect.material = copyMaterial
	pass

func _ready():
	currentKernelGenerator = splitKernelGenerator
	currentKernelGenerator.setUI(true)
	get_tree().get_root().size_changed.connect(resizeBuffers)
	resizeBuffers()
	reset()
	updatePostProcessing()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	currentKernelGenerator.updateKernelsFromSpectogram()
	pass

func _input(event):
	
	if zoom:
		if event.is_action_pressed("Zoom in"):
			bufferWindowRatio = clampf(bufferWindowRatio - 0.1, 0.2, 2)
			resizeBuffers()
		elif event.is_action_pressed("Zoom out"):
			bufferWindowRatio = clampf(bufferWindowRatio + 0.1, 0.2, 2)
			resizeBuffers()
		
	
	if event.is_action_pressed("Toggle Fullscreen"):
		toggleFullscreen()
		
	elif event is InputEventKey:
		if event.pressed:
			if (event.keycode >= 65 && event.keycode < 91):
				$CanvasLayer/MarginContainer.visible = !$CanvasLayer/MarginContainer.visible
	
		
	pass
