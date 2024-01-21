extends StaticBody3D

@onready var anim_tree = $AnimationTree
@onready var sleep_sprite = $sleep_sprite

var timer = 0;
var f_timer = 0;
var fully_asleep = false;
var player= null
var rotation_y = 0;


#if metadata set, set timer
#if dialogue empty, set trigger (dialogue signal from dialogic behavior)
#	+ metadata tag set by player
# if player away & dialogue exhausted, set to sleep, and change dialogue


func _ready () :
	sleep_sprite.visible = false;
	player = $"/root/global".player
	rotation_y = rotation.y;
	
#this get_meta / set_meta block w/ the timer is not the right way to do this, I'm 90% sure

func _look_at_target_interpolated(weight:float) -> void:
	var xform := transform # your transform
	xform = xform.looking_at(player.global_position,Vector3.UP)
	transform = transform.interpolate_with(xform,weight)


func _process (_delta) : 
	if !fully_asleep :
		
		if get_meta("is_sleep") == true :
			timer += 1;
			if timer > 10 :
				timer = 0
				var dist = self.global_position.distance_to($"/root/global".player.global_position)
				if dist > 70 :
					anim_tree.set("parameters/conditions/sleepmode",true)
					sleep_sprite.visible = true;
					#also set dialogue HERE
					set_meta("fully_sleep",true);
					fully_asleep = true;
		
		if get_meta("talk_timer") == true :
			f_timer += 1;
			if f_timer > 1800 :
				print("time out")
				set_meta("talk_timer",false)
				f_timer = 0;
			if get_meta("face_player") == true :
				_look_at_target_interpolated(0.1)
			else :
				rotation.y = lerp(rotation.y,rotation_y,0.1)




