class_name DreamJournal
extends Node

@onready var state_machine = $StateMachine
@onready var anim_sprite = $AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready():
	anim_sprite.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_player_open_book():
	anim_sprite.visible = true
	anim_sprite.play("opening")
