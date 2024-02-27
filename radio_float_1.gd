extends Node3D

@export var audio = ""
@onready var aud_stream = $AudioStreamPlayer3D
@onready var anim_player = $AnimationPlayer

func _ready() :
	aud_stream.stream = load(audio)
	aud_stream.play(0.0);
	anim_player.play("float")

		
