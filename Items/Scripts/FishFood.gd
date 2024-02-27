extends Node3D

@onready var emitter = $GPUParticles3DFood
@onready var audio_player1 = $AudioStreamPlayer3D
@onready var audio_player2 = $AudioStreamPlayer3D2
@onready var timer = $Timer

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_player_fish_eat():
	emitter.emitting = true
	audio_player1.play()
	timer.start()


func _on_timer_timeout():
	audio_player2.play()
