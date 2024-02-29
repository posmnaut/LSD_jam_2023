extends Node3D

@onready var anim_player = $Armature/AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready():
	anim_player.play("idle")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
