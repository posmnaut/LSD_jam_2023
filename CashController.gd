extends Node3D

class_name cash_controller

@onready var emitter1 = $GPUParticles3DSingle
@onready var emitter2 = $GPUParticles3DBrick
@onready var emitter3 = $GPUParticles3DSingle2
@onready var emitter4 = $GPUParticles3DBrick2
@onready var audioPlayer = $AudioStreamPlayer3D

var isPressed = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_player_cash_fire():
	if(isPressed == true):
		isPressed = false
		audioPlayer.play()
		emitter1.emitting = true
		emitter2.emitting = true
		emitter3.emitting = true
		emitter4.emitting = true
