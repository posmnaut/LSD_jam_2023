extends Control

@onready var start_button = $HBoxContainer/VBoxContainer/start as Button
@onready var quit_button = $HBoxContainer/VBoxContainer/quit as Button
@onready var start_level = preload("res://RenderContainer.tscn") as PackedScene 
@onready var blink_anim = $CenterContainer/AnimatedSprite2D
var button_select = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	#DisplayServer.window_set_mode(4,0)
	start_button.button_down.connect(on_start_pressed)
	quit_button.button_down.connect(on_exit_pressed)
	blink_anim.visible = true
	blink_anim.set_frame_and_progress(0,0.0);
	blink_anim.play();

func on_start_pressed() -> void:
	blink_anim.play_backwards()
	button_select = 1
	
func on_exit_pressed() -> void:
	blink_anim.play_backwards()
	button_select = 2
	

func _process(delta) :
	if button_select != 0 :
		if blink_anim.frame == 0.0 :
			if button_select == 1:
				get_tree().change_scene_to_packed(start_level)
			elif button_select == 2:
				get_tree().quit()
			
		
	
	
