extends StaticBody3D
class_name billboard_talkable_NPC

@export var open_audio = ""
@onready var anim_tree = $AnimationTree
@onready var sleep_sprite = $"game rig/sleep_sprite"
@onready var face_sprite = $"game rig/Skeleton3D/BoneAttachment3D/face_sprite"
@export var dialogue_string = "";
@onready var animation_player = $AnimationPlayer

var timer = 0;
var f_timer = 0;
var fully_asleep = false;
var disappear = false;
var set_sleepmode = false;
var player= null
var rotation_y = 0;
var dur_timer = 450.0;
var face_player = false
var is_sleep = false
var talk_timer = false
var timing_int = 100.0
var head_scratch = true
var gone = false


#NOTE:
#NPC talk triggers are partially inside the player entity (ctrl+f NPC)
#NPC talk timer, sleep, and disappear behaviors are set inside the MAIN script


func _ready () :
	sleep_sprite.visible = false;
	player = $"/root/global".player
	rotation_y = global_transform.basis.get_euler().y;
	
#this get_meta / set_meta block w/ the timer is not the right way to do this, I'm 90% sure

func _look_at_target_interpolated(weight:float) -> void:
	var xform := global_transform # your transform
	xform = xform.looking_at(player.global_position,Vector3.UP)
	global_transform = global_transform.interpolate_with(xform,weight)


func _process (delta) : 
	if !fully_asleep :
	
		if is_sleep == true :
			if set_sleepmode :
				anim_tree.set("parameters/conditions/idle_head_scratch_bool",false)
				anim_tree.set("parameters/conditions/sleepmode",true)
				sleep_sprite.visible = true;
				face_sprite.visible = false;
				#also set dialogue HERE
				fully_asleep = true;
				set_sleepmode = false;
				print("sleepmode set")
		
		if talk_timer == true :
			if(head_scratch == true):
				head_scratch = false
				anim_tree.set("parameters/conditions/head_scratch_bool",true)
			elif(animation_player.is_playing() == false && head_scratch == false):
				anim_tree.set("parameters/conditions/head_scratch_bool",false)
				anim_tree.set("parameters/conditions/idle_head_scratch_bool",true)
			#f_timer += timing_int * delta;
			#if f_timer > dur_timer :
				#talk_timer = false
				#f_timer = 0;
			#if face_player == true :
				#_look_at_target_interpolated(0.1)
			#else :
				#rotation.y = lerp_angle(rotation.y,rotation_y,0.1)




