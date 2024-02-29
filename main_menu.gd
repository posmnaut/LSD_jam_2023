extends Control

@onready var start_button = $HBoxContainer/VBoxContainer/start as Button
@onready var quit_button = $HBoxContainer/VBoxContainer/quit as Button
@onready var options_button = $HBoxContainer/VBoxContainer/options as Button
@onready var start_level = preload("res://RenderContainer.tscn") as PackedScene 
@onready var blink_anim = $CenterContainer/AnimatedSprite2D
@onready var options_menu = $options_menu
@onready var hover_audio = $Mouse_Entered
@onready var click_audio = $Mouse_Click
@onready var options_click_audio = $Mouse_Clicked_Options


var button_select = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	#DisplayServer.window_set_mode(4,0)
	start_button.button_down.connect(on_start_pressed)
	options_button.button_down.connect(on_options_pressed)
	quit_button.button_down.connect(on_exit_pressed)
	options_menu.exit_options_menu.connect(on_exit_options_menu)
	blink_anim.visible = true
	blink_anim.set_frame_and_progress(0,0.0);
	blink_anim.play();

func on_start_pressed() -> void:
	blink_anim.play_backwards()
	button_select = 1
	
func on_options_pressed() -> void:
	blink_anim.play_backwards()
	button_select = 2
	
func on_exit_pressed() -> void:
	blink_anim.play_backwards()
	button_select = 3
	
func on_exit_options_menu() -> void:
	vis_swap_main()
	options_menu.visible = false
	blink_anim.visible = true
	blink_anim.set_frame_and_progress(0,0.0);
	blink_anim.play();
	
#this is garbage but I don't have time to fix it 
func vis_swap_main() -> void:
	$TextureRect.visible = !$TextureRect.visible
	$VBoxContainer.visible = !$VBoxContainer.visible
	$HBoxContainer.visible = !$HBoxContainer.visible
	$CenterContainer.visible = !$CenterContainer.visible
	blink_anim.visible = !blink_anim.visible
	

func _process(delta) :
	
	if Input.is_action_just_pressed("f2"):
		button_select = 1
		blink_anim.set_frame_and_progress(0,0.0);
	
	if button_select != 0 :
		if blink_anim.frame == 0.0 :
			if button_select == 1:
				get_tree().change_scene_to_packed(start_level)
				button_select = 0
			elif button_select == 2:
				vis_swap_main()
				options_menu.visible = true
				options_menu.set_process(true)
				options_menu.blink_anim.visible = true
				options_menu.blink_anim.set_frame_and_progress(0,0.0);
				options_menu.blink_anim.play();
				button_select = 0
			elif button_select == 3:
				get_tree().quit()
				button_select = 0
			
		
	
	


func _on_start_mouse_entered():
	hover_audio.play()


func _on_options_mouse_entered():
	hover_audio.play()


func _on_quit_mouse_entered():
	hover_audio.play()


func _on_start_button_down():
	click_audio.play()


func _on_options_button_down():
	options_click_audio.play()


func _on_quit_button_down():
	click_audio.play()
