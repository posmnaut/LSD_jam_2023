extends Node3D

@export var audio = ""
@onready var aud_stream = $AudioStreamPlayer3D

func _ready() :
	aud_stream.stream = load(audio)
	aud_stream.play(0.0);

		
