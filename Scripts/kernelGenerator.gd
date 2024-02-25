extends Node

@export var convolutionMaterial : ShaderMaterial
@export var numberOfKernels : int
@export var textureRect : TextureRect
@export var isSplit : bool
@export var backgroundColor : bool

@export var postProcessingMaterial : ShaderMaterial

@export var foregroundColors = [Color(1,0,0), Color(0,1,0), Color(0,0,1)]
@export var backgroundColors = [Color(0,0,0), Color(0,0,0), Color(0,0,0)]

@export var uiNode : Node


var spectrum
var weights = []
var threads = []
var numberOfKernelWeights : int
var averageKernelValue : float
var rng = RandomNumberGenerator.new()
var outputTexture


func setColor(color : Color, id : int):
	if(id < 0):
		backgroundColors[abs(id)- 1] = color
	else:
		foregroundColors[id - 1] = color
	updatePostProcessing()
	pass

func setUI(on : bool):
	if(uiNode == null):
		return
	uiNode.visible = on
	pass

func setSaturation(on : bool):
	postProcessingMaterial.set_shader_parameter("saturate", on)
	pass	
	
func updatePostProcessing():
	postProcessingMaterial.set_shader_parameter("backgroundColors", backgroundColors)
	postProcessingMaterial.set_shader_parameter("foregroundColors", foregroundColors)
	pass
		
		
func randomizeWeights():
	weights = []
	for i in numberOfKernelWeights:
		var row : PackedFloat32Array
		for j in 512:
			row.append(rng.randf())
		weights.append(row)
	pass	


func multiplyArray(a, b) -> PackedFloat32Array:
	var out : PackedFloat32Array
	for i in a.size():
		var sum :float = 0.0
		for j in b.size():
			sum = sum + a[i][j] * b[j]
		out.append(sum)
	return out

var iter = 0
var numberOfThreads = ceil(numberOfKernelWeights / 20.0)
var matricesPerThread = (3*3*9) / numberOfThreads
var additionalMatrices = numberOfKernelWeights - (numberOfKernelWeights / matricesPerThread)
func updateKernelsFromSpectogram():
	var kernels = []
	var samples : PackedFloat32Array
	

	for i in 512:
		samples.append(linear_to_db(spectrum.get_magnitude_for_frequency_range((i / 512.0) * 20000.0,((i + 1) / 512.0) * 20000.0).length())/ 96.0 + 1.0)
		if samples[i] == -INF:
			samples[i] = 0.0
	
	for i in (numberOfThreads - 1):
		threads.append(Thread.new())
		threads[i].start(multiplyArray.bind(weights.slice(i * matricesPerThread, (i + 1) * matricesPerThread), samples))
	
	var convolutionWeights : PackedFloat32Array	
	convolutionWeights.append_array(multiplyArray(weights.slice((numberOfThreads - 1) * matricesPerThread, numberOfThreads * matricesPerThread + additionalMatrices), samples))
	for i in (numberOfThreads - 1):
		convolutionWeights.append_array(threads[i].wait_to_finish())
	
	
	var index = 0
	var mean = 0.0
	for i in numberOfKernels:
		var kernel = Basis()
		for x in 3:
			for y in 3:
				kernel[x][y] = convolutionWeights[index]
				mean = mean + kernel[x][y]
				index = index + 1
		kernels.append(kernel)

	mean = mean / numberOfKernelWeights
	
	var variance = 0.0
	for i in numberOfKernels:
		for x in 3:
			for y in 3:
				variance = variance + pow(kernels[i][x][y] - mean, 2)
	
	variance = variance / numberOfKernelWeights			
				
	for i in numberOfKernels:
		for x in 3:
			for y in 3:
				kernels[i][x][y] = (kernels[i][x][y] - mean + averageKernelValue) / (sqrt(variance + 0.0001) * 2)

	textureRect.material = convolutionMaterial
	convolutionMaterial.set_shader_parameter("kernels", kernels)

	pass

func _ready():
	if(isSplit):
		averageKernelValue = 1.0 / 9.0
	else:
		averageKernelValue = 1.0 / 81.0
	numberOfKernelWeights = numberOfKernels * 3 * 3
	numberOfThreads = ceil(numberOfKernelWeights / 20.0)
	matricesPerThread = int(numberOfKernelWeights / numberOfThreads)
	additionalMatrices = (numberOfKernelWeights % matricesPerThread)
	spectrum = AudioServer.get_bus_effect_instance(2,0)
	outputTexture = get_node("/root/Node2D/CanvasLayer/TextureRect")
	randomizeWeights()
