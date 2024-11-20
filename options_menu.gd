extends Control

@onready var exit_button = $MarginContainer/ScrollContainer/VBoxContainer/exit as Button
@onready var window_toggle = $MarginContainer/ScrollContainer/VBoxContainer/fullscreen_toggle as Button
@onready var blink_anim = $CenterContainer/AnimatedSprite2D
@onready var hover_audio = $Mouse_Entered
@onready var click_audio = $Mouse_Click

var button_select = 0
var f_screen = false
var type_tag = 0

signal exit_options_menu

# Called when the node enters the scene tree for the first time.
func _ready():
	var viewportWidth = get_viewport().size.x
	var viewportHeight = get_viewport().size.y
	var scale_x = viewportWidth / blink_anim.get_sprite_frames().get_frame_texture("default",0).get_size().x
	var scale_y = viewportHeight / blink_anim.get_sprite_frames().get_frame_texture("default",0).get_size().y
	blink_anim.set_position(Vector2(0.0, 0.0))
	blink_anim.set_scale(Vector2(scale_x, scale_y))
	exit_button.button_down.connect(on_exit_pressed)
	window_toggle.button_down.connect(fullscreen_toggle)
	set_process(false)
	
func fullscreen_toggle() -> void :
	var _win = DisplayServer.window_get_mode(0)
	if _win == 0 :
		DisplayServer.window_set_mode(4,0)
	else :
		DisplayServer.window_set_mode(0,0)
	var viewportWidth = get_viewport().size.x
	var viewportHeight = get_viewport().size.y
	var scale_x = viewportWidth / blink_anim.get_sprite_frames().get_frame_texture("default",0).get_size().x
	var scale_y = viewportHeight / blink_anim.get_sprite_frames().get_frame_texture("default",0).get_size().y
	blink_anim.set_position(Vector2(0.0, 0.0))
	blink_anim.set_scale(Vector2(scale_x, scale_y))

func on_exit_pressed() -> void :
	blink_anim.play_backwards()
	button_select = 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if Input.is_action_just_pressed("escape"):
		button_select = 1
		blink_anim.play_backwards()
	
	if button_select != 0 :
		if blink_anim.frame == 0.0 || type_tag == 1:
			if button_select == 1:
				exit_options_menu.emit()
				set_process(false)
				button_select = 0
				type_tag = 0;


func _on_fullscreen_toggle_mouse_entered():
	hover_audio.play()


func _on_exit_mouse_entered():
	hover_audio.play()


func _on_exit_button_down():
	click_audio.play()


func _on_fullscreen_toggle_button_down():
	click_audio.play()
