extends Node3D

@export var audio: AudioStreamMP3
@onready var aud_stream = $AudioStreamPlayer3D

const lsd_mix = preload("res://music/LSD_Project.mp3")

func _on_ready() :
	aud_stream.stream = lsd_mix
	aud_stream.play();
	
