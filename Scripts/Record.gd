extends Node

var effect
var recording
var streamPlayer
var timer

# Called when the node enters the scene tree for the first time.
func _ready():
	streamPlayer = get_node("/root/Node2D/AudioStreamPlayer2")
	timer = get_node("/root/Node2D/RecordingTimer")
	effect = AudioServer.get_bus_effect(2, 1)
	pass # Replace with function body.

func _on_record_button_pressed():
	if effect.is_recording_active():
		recording = effect.get_recording()
		$Playback.disabled = false
		effect.set_recording_active(false)
		$Record.text = "Record"
	else:
		$Playback.disabled = true
		effect.set_recording_active(true)
		$Record.text = "Stop"
		timer.start(5)
		await timer.timeout
		recording = effect.get_recording()
		effect.set_recording_active(false)
		$Playback.disabled = false
		$Record.text = "Record"
	pass

func _on_play_button_pressed():
	var data = recording.get_data()
	streamPlayer.stream = recording
	streamPlayer.play()
	pass
