class_name DreamJournalSM
extends Node

#@onready var state_machine = $StateMachine
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


func _on_player_close_book():
	anim_sprite.visible = true
	anim_sprite.play("closing")



func _on_animated_sprite_2d_animation_finished():
	if(anim_sprite.animation == "closing"):
		anim_sprite.visible = false


func _on_player_page_left():
	anim_sprite.play("flip_pageL")


func _on_player_page_right():
	anim_sprite.play("flip_pageR")
