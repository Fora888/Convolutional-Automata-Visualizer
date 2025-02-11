extends Node

@export var convolutionMaterial : ShaderMaterial
@export var numberOfKernels : int
@export var textureRect : TextureRect
@export var is3D : bool
@export var backgroundColor : bool

@export var postProcessingMaterial : ShaderMaterial

@export var foregroundColors = [Color(1,0,0), Color(0,1,0), Color(0,0,1)]
@export var backgroundColors = [Color(0,0,0), Color(0,0,0), Color(0,0,0)]

@export var uiNode : Node
@export var spectogramBar : PackedScene
@export var spectogramContainer : HBoxContainer
var targetAverage = 0.5
var targetVariance = 1.0
var spectogramBars = []

var spectrum
var weights = []
var threads = []
var numberOfKernelWeights : int
var averageKernelValue : float
var rng = RandomNumberGenerator.new()
var outputTexture
var noise = FastNoiseLite.new()

var emaAlpha = 0.5
var emaHistory: PackedFloat32Array
var reactivity = 0.5


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
	emaHistory.resize(512)
	emaHistory.fill(0)
	for i in numberOfKernelWeights:
		var row : PackedFloat32Array
		var sum = 0
		var randomRow = rng.randf_range(-1.0, 1.0) * 500
		for j in 512:
			#row.append(noise.get_noise_2d(j, randomRow))
			row.append(randf())
			sum = sum + (row[-1] ** 2)
		sum = sqrt(sum)
		for j in 512:
			row[j] = row[j] / sum
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
		samples.append(linear_to_db(spectrum.get_magnitude_for_frequency_range((i / 512.0) * 2000.0,((i + 1) / 512.0) * 2000.0).length())/ 72.0 + 1.0)
		if samples[i] == -INF or samples[i] < 0.0:
			samples[i] = 0.0
		
		var historicLoudness = emaHistory[i]
		emaHistory[i] = emaAlpha * samples[i] + (1-emaAlpha) * emaHistory[i]
		samples[i] = samples[i] - reactivity * historicLoudness
		
		
		if spectogramBars.size() != 0:
			(spectogramBars[i] as Panel).custom_minimum_size = Vector2(0, samples[-1] * 100)
		

		
	
	for i in (numberOfThreads - 1):
		threads.append(Thread.new())
		threads[i].start(multiplyArray.bind(weights.slice(i * matricesPerThread, (i + 1) * matricesPerThread), samples))
	
	var convolutionWeights : PackedFloat32Array	
	convolutionWeights.append_array(multiplyArray(weights.slice((numberOfThreads - 1) * matricesPerThread, numberOfThreads * matricesPerThread + additionalMatrices), samples))
	for i in (numberOfThreads - 1):
		convolutionWeights.append_array(threads[i].wait_to_finish())
	
	#basicly needs a complete rewrite. 
	
	var index = 0
	var mean = []
	mean.resize(numberOfKernels)
	mean.fill(0.0)
	for i in numberOfKernels:
		for j in (3 if is3D else 1):
			var kernel = Basis()
			for x in 3:
				for y in 3:
					kernel[x][y] = convolutionWeights[index]
					mean[i] = mean[i] + kernel[x][y]
					index = index + 1
			kernels.append(kernel)
	
	for i in numberOfKernels:
		if(is3D):
			mean[i] = mean[i] / 27.0
		else:
			mean[i] = mean[i] / 9.0
	
	var variance = []
	variance.resize(numberOfKernels)
	variance.fill(0.0)
	for i in numberOfKernels:
		for j in (3 if is3D else 1):
			for x in 3:
				for y in 3:
					var kernelIndex = (i * 3 + j) if is3D else i
					variance[i] = variance[i] + pow(kernels[kernelIndex][x][y] - mean[i], 2)
					#variance = max(variance, abs(kernels[i][x][y] - mean))
	
	for i in numberOfKernels:
		if(is3D):
			variance[i] = variance[i] / 27.0		
		else:
			variance[i] = variance[i] / 9.0			
				
	for i in numberOfKernels:
		for j in (3 if is3D else 1):
			for x in 3:
				for y in 3:
					var kernelIndex = (i * 3 + j) if is3D else i
					kernels[kernelIndex][x][y] = ((kernels[kernelIndex][x][y] - mean[i] ) / sqrt(variance[i] + 0.0001)) * targetVariance  + averageKernelValue #Mit varianz und Durschnitt spielen
					#kernels[i][x][y] = (kernels[i][x][y] - mean + averageKernelValue) / variance
	#print(str(kernels[0][0][0]) + ", " + str(kernels[0][0][1]) + ", " + str(kernels[0][0][2]) + ", " + str(kernels[0][1][0]) + ", " + str(kernels[0][1][1]) + ", " + str(kernels[0][1][2]) + ", " + str(kernels[0][2][0]) + ", " + str(kernels[0][2][1]) + ", " + str(kernels[0][2][2]))
	
	textureRect.material = convolutionMaterial
	convolutionMaterial.set_shader_parameter("kernels", kernels)

	pass

func _ready():
	if(is3D):
		averageKernelValue = targetAverage / 27.0
		numberOfKernelWeights = numberOfKernels * 3 * 3 * 3
	else:
		averageKernelValue = targetAverage / 9.0
		numberOfKernelWeights = numberOfKernels * 3 * 3
	
	numberOfThreads = ceil(numberOfKernelWeights / 20.0)
	matricesPerThread = int(numberOfKernelWeights / numberOfThreads)
	additionalMatrices = (numberOfKernelWeights % matricesPerThread)
	spectrum = AudioServer.get_bus_effect_instance(2,0)
	outputTexture = get_node("/root/Node2D/CanvasLayer/TextureRect")
	if spectogramBar != null && spectogramContainer != null:	
		for j in 512:
			spectogramBars.append(spectogramBar.instantiate())
			spectogramContainer.add_child(spectogramBars[-1])
	randomizeWeights()
	
func setAverage(value):
	targetAverage = value
	if(is3D):
		averageKernelValue = targetAverage / 27.0
	else:
		averageKernelValue = targetAverage / 9.0
