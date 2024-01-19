extends StaticBody3D

@onready var anim_tree = $AnimationTree

var timer = 0;
var f_timer = 0;
var fully_asleep = false;
var player= null


#if metadata set, set timer
#if dialogue empty, set trigger (dialogue signal from dialogic behavior)
#	+ metadata tag set by player
# if player away & dialogue exhausted, set to sleep, and change dialogue


func _ready () :
	pass
	
#this get_meta / set_meta block w/ the timer is not the right way to do this, I'm 90% sure
	
func _process (_delta) : 
	if !fully_asleep :
		
		if get_meta("is_sleep") == true :
			timer += 1;
			if timer > 10 :
				timer = 0
				var dist = self.global_position.distance_to($"/root/global".player.global_position)
				if dist > 70 :
					anim_tree.set("parameters/conditions/sleepmode",true)
					#also set dialogue HERE
					set_meta("fully_sleep",true);
					fully_asleep = true;
		
		if get_meta("talk_timer") == true :
			f_timer += 1;
			if f_timer > 1800 :
				print("time out")
				set_meta("talk_timer",false)
				f_timer = 0;
			#if get_meta("face_player") == true :
				#var target_vector = global_position.direction_to(player)
				#var target_basis= Basis.looking_at(target_vector)
				#basis = basis.slerp(target_basis, 0.5)
			#else :
				#pass




