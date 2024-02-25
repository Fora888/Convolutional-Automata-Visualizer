# Convolutional Automata Visualizer
A music visualizer based on neural cellular automata

The web version is available at [https://fora888.github.io/Convolutional-Automata-Visualizer/](https://fora888.github.io/Convolutional-Automata-Visualizer/)

Downloadable executables can be found at [/Build/Executable](/Build/Executable)

## How it works
The foundation of this Project are neural cellular automata. A great explanation for these can be found in [this video](https://www.youtube.com/watch?v=3H79ZcBuw4M) . Essentially, neural cellular automata consist of a convolutional kernel wich repeatedly gets applied to an image. In this implementation the weights of the kernel are determined by the spectrum of audio. This is accomplished by multiplying the intensity of each frequency by a different weight and then summing the result of all frequency to obtain one weight of the convolution kernel. This process is repeated with different weights for the spectrum for each weight of the convolution kernel. The mean and deviation of all values in the kernel are then adjusted to make it less likely that a kernel results in a fully white or black image. Finally the kernel gets applied to the image to obtain the next frame and the process is repeated

This already results in pretty interesting patterns, but to make matters more interesting there are two modes which work with all three channels of an RGB image

**3 Channel Split** treats each channel seperatly with its own convolution kernel. Thus the new value of a buffer is only determined by neighbours of the same buffer. This results in the same patterns as with the Single channel algorithm layered on top of each other in different colors

**3 Channel Full** also consideres the neighbors in the other two buffers. Here three 3x3x3 kernels are used in a 3D convolution. The results are far more chaotic patterns

## Known Issues
The HTML5 version doesn't currently work on IOS devices due to a issue in Godot, where microphone input cannot be obtained on these devices
