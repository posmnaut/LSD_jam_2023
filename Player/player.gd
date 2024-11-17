extends CharacterBody3D

const JUMP_VELOCITY = 12*0.8
var wall_jump_y_velocity = 14
var mouseSensibility = 1000
var mouse_relative_x = 0
var mouse_relative_y = 0
var jump_token = 2;
var consecWallJumps = 0;

@onready var ray_upper = $Head/Upper_Check
@onready var ray_lower = $Head/Lower_Check
@onready var ray_shadow = $D_Shad_Check
@onready var camera = $Head/Camera3D
@onready var head = $Head
@onready var drop_shadow = $Drop_Shadow
@onready var stp_audio_player = $footsteps_1
@onready var Look_Cast = $Head/Look_Cast_NPC
@onready var look_cast_door = $Head/Look_Cast_door
@onready var look_cast_cash = $Head/Camera3D/Look_Cast_cash
@onready var look_cast_fish = $Head/Camera3D/FishFood
@onready var look_cast_boots = $Head/Camera3D/BunnyBoots
@onready var look_cast_comp = $Head/Camera3D/Keyboard_Cast
@onready var hud_RTL = $UI/RichTextLabel;
@onready var blink_anim = $UI/Control/AnimatedSprite2D as AnimatedSprite2D
@onready var audio_s_player = $AudioStreamPlayer
@onready var fog_color_default
@onready var fog_density_default
@onready var interact_sprite = $UI/Control/sprite_pointer
@onready var bump_trigger_detect = $Area3D
@onready var p_collider = $CollisionShape3D
@onready var default_height
@onready var head_bonk = $head_bonk
@onready var ladder_detection = $ladder_detection
@onready var pause_menu = $UI/VBoxContainer
@onready var part_rain = $particles/rain_1
@onready var part_m_snow = $particles/marine_snow_1
@onready var options_menu = $UI/options_menu
@onready var timer_shake = $Timer
@onready var audiosubplayer2 = $sub_player_2


@export var spwn_point : Node3D
@export var environ_a : WorldEnvironment

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = 30.0
var fall = 30.0
var bs_spd = 5.0
var wall_run_spd = 12.0
var spd = 5.0
var spd_crch_mod = 0.5
var p_normal
var wall_run_t = 0.0
var direction
var is_wallrunning = false
var side = ""
var wall_jump = false
var is_wall_run_jumping = 0
var wall_jump_dir = Vector3.ZERO
var wall_jump_factor = 0.45 #export me
var wall_jump_h_power = 2.0 #export me
var wall_climb_strength = 4 #export me
var mantling = false
var sprint_mod = 2
var sprint_spd = 0
var land_audio = false;
var fov_default = 0.0;
var fov_sprint = 0.0;
var sprint = false;
var eyes_state = 0;
var eyes_state_sub_timer = 0
var close_game = false
var fall_fade = 0;
var fall_color_white = Color(Color.WHITE)
var fall_tween 
var point_timer = 0
var fog_fade = false
var teleport_point 
var fall_thresh = 100;
var crouch_speed = 20;
var crouch_height = 0;
var head_default = 0;
var ceil_too_low = false
var on_ladder = false
var can_wall_run = true
var pause = false
var blink_frames = 0
var collisionInst = null
var wallTouched = false
var allowWallJump = false
var NPCinst = null
var fish_clicked = false
var fired_cash = false
var bootGrabbed = false
var cam_shake = false
var shake_strength = 0.0
var SHAKE_DECAY_RATE = 0.35
var accBunnyHop = false
var BUNNY_SPEED_MULT = 0.0
var frame_check = 0
var bunny_fired = false
var compClicked = false
var bookState = "closed"
var journalLocked = false

var wall_run_angle = 15 #export me 
var wall_run_current_angle = 0
var wall_run_fov = 90
var wall_run_current_FOV = 0
@onready var wall_run_default_fov = $Head/Camera3D.fov

var wall_run_x_rot = 0
var wall_run_x_vec = Vector2.ZERO
var wall_run_dir_ex = 0
var dot_ex = 0

var step_timer = 0;

var in_dialogue = false;

signal click_teleport(audio)
signal cash_fire
signal fish_eat
signal fade_environ_shift
signal bootsGrabbedSignal
signal fade_env_shif_override
signal compClickedSignal
signal openBook
signal pageLeft
signal pageRight
signal closeBook

var teleload = true

func _ready():
	$"/root/global".register_player(self)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED #captures mouse inside the screenspace
	Dialogic.timeline_ended.connect(_on_timeline_ended)
	Dialogic.signal_event.connect(_on_dialogic_signal)
	fov_default = camera.fov;
	fov_sprint = fov_default + 5.0;
	blink_anim.set_frame_and_progress(0,0.0);
	blink_anim.play();
	
	fog_density_default = environ_a.environment.get_fog_density()
	fog_color_default = environ_a.environment.get_fog_light_color()
	Dialogic.start("timeline_null_reset") #this preloads the dialogic system
	default_height = p_collider.scale.y
	crouch_height = default_height*0.6
	head_default = head.position.y
	#process_mode = Node.PROCESS_MODE_ALWAYS;
	part_m_snow.visible = true;
	part_rain.visible = false;
	options_menu.visible = false
	options_menu.exit_options_menu.connect(on_exit_options_menu)
	
	var viewportWidth = get_viewport().size.x
	var viewportHeight = get_viewport().size.y
	var scale = viewportWidth / blink_anim.get_sprite_frames().get_frame_texture("default",0).get_size().x
	blink_anim.set_position(Vector2(0.0, 0.0))
	blink_anim.set_scale(Vector2(scale, scale))
	
	
func _on_quit_pressed():
	get_tree().quit()

func _on_options_pressed():
	vis_swap_main()
	options_menu.visible = true
	options_menu.set_process(true)
	options_menu.blink_anim.visible = false
	options_menu.type_tag = 1
	
func on_exit_options_menu() -> void:
	vis_swap_main()
	options_menu.visible = false
	options_menu.set_process(false)
	var viewportWidth = get_viewport().size.x
	var viewportHeight = get_viewport().size.y
	var scale = viewportWidth / blink_anim.get_sprite_frames().get_frame_texture("default",0).get_size().x
	blink_anim.set_position(Vector2(0.0, 0.0))
	blink_anim.set_scale(Vector2(scale, scale))
	
	
func vis_swap_main() -> void:
	$UI/Control.visible = !$UI/Control.visible
	$UI/VBoxContainer.visible = !$UI/VBoxContainer.visible
	$UI/VBoxContainer/resume.visible = !$UI/VBoxContainer/resume.visible
	$UI/VBoxContainer/options.visible = !$UI/VBoxContainer/options.visible
	$UI/VBoxContainer/quit.visible = !$UI/VBoxContainer/quit.visible
		
func _on_resume_pressed():
	pause = !pause
	blink_anim.play()

func _process(delta):
	
	if(journalLocked == true):
		interact_sprite.visible = true
		interact_sprite.global_position = get_viewport().get_mouse_position()
	
	if(cam_shake == true):
		shake_strength = lerp(shake_strength, 0.0, SHAKE_DECAY_RATE * delta)
		camera.h_offset = randf_range(-shake_strength, shake_strength)
		camera.v_offset = randf_range(-shake_strength, shake_strength)
		
	if step_timer > 30 :
		step_timer = 0;
		stp_audio_player.pitch_scale = randf_range(0.7,1.3);
		stp_audio_player.play()
		
	#close game loop
	#plays anim then pauses then closes
	#if close_game :
		#if !blink_anim.is_playing() :
		#	blink_anim.play_backwards();
			
		#if blink_anim.frame == 0 || eyes_state_sub_timer > 0:
		#	blink_anim.set_frame_and_progress(0,0.0);
		#	eyes_state_sub_timer += 1;
		#	if eyes_state_sub_timer >= 15 :
		#		#get_tree().quit()
		#		pass
		
	if pause:
		if blink_anim.frame == 0 :
			blink_anim.set_frame_and_progress(0,0.0);
			pause_menu.show()
			#get_tree().paused = true
			Engine.time_scale = 0
			#also disable movement here
			Input.mouse_mode = Input.MOUSE_MODE_CONFINED #captures mouse inside the screenspace
	elif(journalLocked == true):
		Input.mouse_mode = Input.MOUSE_MODE_CONFINED_HIDDEN
	else:
		pause_menu.hide()
			#get_tree().paused = true
		Engine.time_scale = 1
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED #captures mouse inside the screenspace

				
	#draw "can interact" icon
	if !in_dialogue && !fog_fade:
		var NPC_check = Look_Cast.get_collider();
		var door_check = look_cast_door.get_collider();
		var cash_check = look_cast_cash.get_collider();
		var fish_check = look_cast_fish.get_collider();
		var boot_check = look_cast_boots.get_collider();
		var comp_check = look_cast_comp.get_collider();
		
		if NPC_check != null || door_check != null || cash_check != null  || fish_check != null && fish_clicked == false || cash_check != null && fired_cash == false || boot_check != null && bootGrabbed == false || comp_check != null && compClicked == false:
			if NPC_check != null:
				if NPC_check.fully_asleep || NPC_check.is_sleep :
					interact_sprite.visible = false
				else:
					interact_sprite.position = Vector2(960.0, 514.0)
					interact_sprite.visible = true
			else:	
				interact_sprite.visible = true
				
			point_timer += 300 * delta
			if point_timer > 359 :
				point_timer = point_timer - 360;
			var _s = (1+sin(deg_to_rad(point_timer))) *0.2;
			interact_sprite.scale.x = 0.75+_s
			interact_sprite.scale.y = 0.75+_s
		elif(journalLocked == true):
			pass
		else :
			interact_sprite.visible = false
		if NPC_check != null :
			NPC_check.face_player = false
	elif(journalLocked == true):
		pass
	else :
		interact_sprite.visible = false
		
	#falling fade out behavior
	if fog_fade == true :
		blink_anim.visible = false
		if 	fall_fade == 0 :
			fog_density_default = environ_a.environment.get_fog_density()
			fog_color_default = environ_a.environment.get_fog_light_color()
			fall_tween = create_tween()
			fall_tween.set_parallel(true)
			fall_tween.tween_property(environ_a.environment, "fog_density", 2.0,2.0)
			fall_tween.tween_property(environ_a.environment, "fog_light_color", fall_color_white,3.0)
			fall_tween.finished.connect(set.bind("fall_fade", 2 ))
			fall_fade = 1
	
		if fall_fade > 1 :
			# this handles position teleportation
			if teleport_point != null :
				fade_env_shif_override.emit()
				position = teleport_point.global_position
				rotation.y = teleport_point.rotation.y
				teleport_point = null
			else :
				position = spwn_point.global_position
				rotation.y = spwn_point.rotation.y

			fall_tween = create_tween()
			fall_tween.set_parallel(true)
			fall_tween.tween_property(environ_a.environment, "fog_density", fog_density_default,3.0)
			fall_tween.tween_property(environ_a.environment, "fog_light_color", fog_color_default,3.0)
			fall_tween.finished.connect(set.bind("fall_fade", 0 ))
			fog_fade = false
			
	else :
		blink_anim.visible = true
			
	#check ceiling depth when crouching
	ceil_too_low = false
	if head_bonk.is_colliding() :
		ceil_too_low = true
		

#if dialogic "end" signal sent, in_dialogue = false 
func _on_timeline_ended():
	in_dialogue = false;
	
#checks for dialogic signals w/ string arguments and does "something"
func _on_dialogic_signal(argument:String):
	if argument == "d_end":
		in_dialogue = false;
		print("Something was activated!")
	#puts faced NPC to sleep if dialogue is exhausted
	if argument == "dialogue_exhausted":
		var NPC_check = Look_Cast.get_collider();
		if NPC_check != null :
			if is_instance_of(NPC_check,talkable_NPC) || is_instance_of(NPC_check,billboard_talkable_NPC) || is_instance_of(NPC_check,construction_talkable_NPC) || is_instance_of(NPC_check,edge_talkable_NPC):
				NPC_check.is_sleep = true;
				NPC_check.dia_finished = true;

func _input(event):
	
	if(event.is_action_pressed("journal") && pause == false):
		if(bookState == "closed"):
			journalLocked = true
			bookState = "opened"
			openBook.emit()
		elif(bookState == "opened"):
			journalLocked = false
			bookState = "closed"
			closeBook.emit()
	
	#Handle escape quit function
	if event.is_action_pressed("escape") && journalLocked == false:
		#close_game = true;
		if blink_anim.frame == 0 || blink_anim.sprite_frames.get_frame_count(blink_anim.animation) :
			pause = !pause
			if pause :
				blink_anim.play_backwards();
			else :
				blink_anim.play()
				

	#this is organized terribly, fix it 
	#Handle NPC talk w/ shoot 
	#Handle click trigger
	if Input.is_action_pressed("shoot") && in_dialogue == false:
		if !fog_fade :		
			var NPC_check = Look_Cast.get_collider();
			var click_check = look_cast_door.get_collider();
			var cash_check = look_cast_cash.get_collider();
			var fish_check = look_cast_fish.get_collider();
			var boot_check = look_cast_boots.get_collider();
			var comp_check = look_cast_comp.get_collider();
			
			if NPC_check != null :
					

				if is_instance_of(NPC_check,talkable_NPC) || is_instance_of(NPC_check,billboard_talkable_NPC) || is_instance_of(NPC_check,construction_talkable_NPC) || is_instance_of(NPC_check,edge_talkable_NPC):
					if Look_Cast.get_collider_rid() != NPCinst :
						Dialogic.VAR.linear_null = 0
						NPCinst = Look_Cast.get_collider_rid()


					var dialogue_string = NPC_check.dialogue_string
					var op_audio = NPC_check.open_audio;
					var talk_timer = NPC_check.talk_timer;
					var is_asleep  = NPC_check.fully_asleep;
					NPC_check.face_player = true
					if !NPC_check.dia_finished :
						if !is_asleep :
							if dialogue_string != "" :
								Dialogic.start(dialogue_string)
								in_dialogue = true;
								if op_audio != "" && op_audio != null:
									if !audio_s_player.is_playing() :
										if talk_timer == false :
											audio_s_player.pitch_scale = 1.0
											audio_s_player.stream = load(op_audio);
											audio_s_player.volume_db = -10.0
											audio_s_player.play();
											NPC_check.talk_timer = true
			elif(is_instance_of(cash_check, cash_body)):
				fired_cash = true
				cash_fire.emit()
			#elif(cash_check != null)
			elif(fish_check != null && fish_check.name == "FishStaticBody" && fish_clicked == false):
				fish_clicked = true
				fish_eat.emit()
			elif(boot_check != null && boot_check.name == "BootsStaticBody" && bootGrabbed == false):
				bootGrabbed = true
				bootsGrabbedSignal.emit()
			elif(comp_check != null && comp_check.name == "CompStaticBody" && compClicked == false):
				print("FIRED")
				compClicked = true
				compClickedSignal.emit()
				
			
			if click_check !=null:
				teleport_point = click_check.get_parent().target_point;
				click_teleport.emit(click_check.get_parent().audio);
				if !audio_s_player.is_playing() :
					audio_s_player.stream = load("res://snd_effects/Teleport_Woosh_-_LSD.wav");
					audio_s_player.volume_db = -10.0
					audio_s_player.play();
				fog_fade = true

	
#Handle camera look / aim
	if fog_fade == false :
		if event is InputEventMouseMotion && journalLocked == false:
			rotation.y -= event.relative.x / mouseSensibility 
			camera.rotation.x -= event.relative.y / mouseSensibility
			camera.rotation.x = clamp(camera.rotation.x,deg_to_rad(-90),deg_to_rad(90))
			mouse_relative_x = clamp(event.relative.x,deg_to_rad(-50),deg_to_rad(50))
			mouse_relative_y = clamp(event.relative.y,deg_to_rad(-50),deg_to_rad(50))
		
func wall_run():
	if is_on_wall() && Input.is_action_pressed("forward") && Input.is_action_pressed("duck") && !is_on_floor() && !mantling:
		var normal = get_wall_normal()
		var collision = get_slide_collision(0)
		var is_wallrunable
		if collision.get_collider().has_meta("is_wallrunable") :
			is_wallrunable = collision.get_collider().get_meta("is_wallrunable") 
		
		var wall_run_dir = Vector3.UP.cross(normal)
		var player_view_dir = -camera.global_transform.basis.z
		var dot = wall_run_dir.dot(player_view_dir)
		if dot < 0 :
			wall_run_dir = -wall_run_dir
			
		wall_run_dir_ex = wall_run_dir
		
		var look_direction = atan2(-wall_run_dir.x, -wall_run_dir.z)
		var offset = abs(rad_to_deg(angle_to_angle(look_direction,rotation.y)))
#		var v = Vector2(normal.x,normal.z)
#		var b = Vector2(direction.x,direction.z)
#		var c = abs(rad_to_deg(v.angle_to(b)))
		
		#$RichTextLabel.text = str(is_wallrunable)
		
		if (offset < 45 or is_wallrunning) && is_wallrunable:
			wall_run_dir += -normal * 1 #adds force to the wall so the player "sticks" to it
			velocity.y = 0
			velocity.y -= 0.01
			
			
			#NOTE: Added a little more strength to the look direction change, that way you feel more in control ->
			#-> by being able to change direction more easily (also lets you do cool corkskrew runs)
			#IMPORTANT NOTE: I LOVE WHAT YOU DID HERE TO MAKE THE WALL RUN WORK!
			velocity.y += camera.rotation.x * wall_climb_strength * 2
			
			direction = wall_run_dir
			side = get_side(collision.get_position())
			wall_run_x_rot = rad_to_deg(Vector2(wall_run_dir.x,wall_run_dir.z).angle())
			wall_run_x_vec = Vector2(wall_run_dir.x,wall_run_dir.z)
			is_wallrunning = true
			is_wall_run_jumping = 0
			if spd < wall_run_spd :
				spd = wall_run_spd
			#spd += 0.1
	else :
		is_wallrunning = false
	

func get_side(point):
	point = to_local(point)
	
	if point.x > 0:
		return "RIGHT"
	elif point.x < 0:
		return "LEFT"
	else:
		return "CENTER"
	
func angle_to_angle(from, to): #for radians
	return fposmod(to-from + PI, PI*2) - PI	
	
func angle_difference(angle1, angle2): #for degrees
	var diff = angle2 - angle1
	return diff if abs(diff) < 180 else diff + (360 * -sign(diff))

func process_wall_run_rotation(delta) :
	if is_wallrunning :
		if side == "RIGHT" :
			wall_run_current_angle += delta * 60
			wall_run_current_angle = clamp(wall_run_current_angle, -wall_run_angle,wall_run_angle)
			#this determines the look y rotation clamp when wallrunning 
			var look_direction = atan2(-wall_run_dir_ex.x, -wall_run_dir_ex.z)
			var offset = rad_to_deg(angle_to_angle(look_direction,rotation.y))
			offset = clamp(offset,-40,40)
			rotation.y = look_direction + deg_to_rad(offset)
			#$RichTextLabel.text = str(offset)
			
				
		elif side == "LEFT" :
			wall_run_current_angle -= delta * 60
			wall_run_current_angle = clamp(wall_run_current_angle, -wall_run_angle,wall_run_angle)
			#this determines the look y rotation clamp when wallrunning 
			var look_direction = atan2(-wall_run_dir_ex.x, -wall_run_dir_ex.z)
			var offset = rad_to_deg(angle_to_angle(look_direction,rotation.y))
			offset = clamp(offset,-40,40)
			rotation.y = look_direction + deg_to_rad(offset)
			#$RichTextLabel.text = str(offset)

		wall_run_current_FOV += delta * 60
		wall_run_current_FOV = clamp(wall_run_current_FOV, -wall_run_fov,wall_run_fov)
		
	else :
		if wall_run_current_angle > 0 :
			wall_run_current_angle -= delta * 40
			wall_run_current_angle = max(wall_run_current_angle, 0)
		elif wall_run_current_angle < 0 :
			wall_run_current_angle += delta * 40
			wall_run_current_angle = min(wall_run_current_angle, 0)
			
		if wall_run_current_FOV > wall_run_default_fov :
			wall_run_current_FOV -= delta * 40
			wall_run_current_FOV = max(wall_run_current_FOV, 0)
			
	camera.rotation_degrees.z = wall_run_current_angle
	##camera.fov = wall_run_current_FOV ##this causes huge lag; why? 

func _physics_process(delta):
	
	if teleload :
		return
	
	#ladder detection
	#door detection
	#donk block detection
	#PLEASE NOTE: these checks are only made on the first object in the collision
	#array. this means you CANNOT overlap multple objects of this type; only the
	#first will trigger
	
	if ladder_detection.has_overlapping_areas() :
		var collision = ladder_detection.get_overlapping_areas();
		var check = collision[0].get_parent();
		
		if is_instance_of(check,ladder):
			on_ladder = true
			can_wall_run = false
			wall_run_t = false
			is_wallrunning = false
			wall_jump = false
			if stp_audio_player.stream != load("res://snd_effects/player/Metal_Walk_Sample.wav") :
				stp_audio_player.stream = load("res://snd_effects/player/Metal_Walk_Sample.wav")
			
		if is_instance_of(check,door):
			var test_a = check.global_transform.origin - global_transform.origin;
			var _dot = test_a.dot(check.global_transform.basis.z)
			check.swing = true
			check.swing_direction = _dot
			
		if is_instance_of(check,block_wallrun_donk):
			can_wall_run = false
			is_wallrunning = false
			wall_run_t = false
	else:
		if stp_audio_player.stream != load("res://snd_effects/Concrete_-_Left_Foot_Step.wav") :
			stp_audio_player.stream = load("res://snd_effects/Concrete_-_Left_Foot_Step.wav")
		on_ladder = false
		can_wall_run = true

	
	#bump trigger detection
	if fog_fade == false :
		if bump_trigger_detect.has_overlapping_areas() :
			var collision = bump_trigger_detect.get_overlapping_areas()
			var check = collision[0].get_parent().target_point
			if check != null :
				teleport_point = check
				fog_fade = true

	# FALLING reposition trigger + behavior 
	if position.y < -fall_thresh:
		fog_fade = true
				
	
	if is_on_floor():
		frame_check += 1
		if(bootGrabbed == true):
			#IMPORTANT NOTE: We check to see if `accBunnyHop` is `false` in the `if-statement` below because we only want the ->
			#-> `BUNNY_SPEED_MULT` to increase one time per each instance of touching the `floor`, to do this we check to see if we ->
			#-> already increased `BUNNY_SPEED_MULT` previously (and the player did not "re-touch" the `floor` yet). We use ->
			#-> `accBunnyHop` as this check because it will only flip from `false` to `true` one time between touching the `floor`, ->
			#-> jumping, and touching the `floor` again.
			if(frame_check <= 8):
				#IMPORTANT NOTE: IF you dont want the player to be able to "charge up" a jump and then move forward to expell it all at ->
				#-> once, then make sure the player is pressing `forward` to gain `BUNNY_SPEED_MULT`
				#IMPORTANT NOTE: The speed of the player while bunny-hopping grows EXPONENTIALLY.
				if(Input.is_action_just_pressed("ui_accept") && bunny_fired == false):
					#if(BUNNY_SPEED_MULT < 1.65):
						#BUNNY_SPEED_MULT += 0.4
					if(spd < 14):
						BUNNY_SPEED_MULT = 2.0
						spd += BUNNY_SPEED_MULT
					bunny_fired = true
					accBunnyHop = true
			else:
				BUNNY_SPEED_MULT = 0.0
				bunny_fired = false
				accBunnyHop = false
				spd = bs_spd
				#if(spd > bs_spd):
					#spd -= 4.0
		
		#NOTE: This `if-statement` will never be met unless the `frame_check <= 6` condition is not met in the previous nested ->
		#-> `if-statement`. This is important because we only want the `spd` of the player to be reset when the player messes up ->
		#-> a bunny-hop jump.
		if(bootGrabbed == false):
			spd = bs_spd
		
		wall_run_t = 0
		is_wall_run_jumping = 0
		jump_token = 2;
		consecWallJumps = 0
		collisionInst = null
		wallTouched = false
		allowWallJump = true
		if land_audio :
			#i would turn the below into a function since you're repeating it 
			land_audio = false
			step_timer = 0;
			stp_audio_player.pitch_scale = randf_range(0.7,1.3);
			stp_audio_player.play()
	#NOTE: This `if-statement` allows for the player to do wall jumps on "non-sliding" walls up to a certain ->
	#-> number of wall jumps (currently `2`).
	elif(is_on_floor() == false && get_slide_collision_count() != 0 && consecWallJumps < 2 && is_wallrunning == false && get_slide_collision(0).get_collider_id() != collisionInst && mantling == false && allowWallJump == true):
		#IMPORTANT NOTE: If you want the player to maintain bunny-hop speed after wall-climbing, then un-comment this.
		# wasPrevOnFloor = false
		#IMPORANT NOTE: We only want the players x-velocity to increase when they just touched the ground AND hit the ->
		#-> jump button, so we need to prevent them from gaining speed otherwise (i.e., wall-climbing or in mid-air).
		#accBunnyHop = false
		bunny_fired = false
		
		if(wallTouched == false && jump_token == 0):
			allowWallJump = false
			jump_token -= 1
		else:
			wallTouched = true
			collisionInst = get_slide_collision(0).get_collider_id()
			consecWallJumps += 1
			#NOTE: I re-assign the `jump_token` variable to `1` instead of doing `jump_token += 1` because it ->
			#-> prevents the double jump AND the wall jump from being used (prevents the three jump up a single ->
			#-> wall, allowing players to get to places they shouldn't). Another way to put it is, you either ->
			#-> double jump OR you wall jump, not a mix of the two.
			jump_token = 1
			velocity.y += JUMP_VELOCITY/4
			#print("I jumped!")
			#hud_RTL.text = str(get_slide_collision(0).get_collider_id())
	#NOTE: This `if-statement` means the player is currently in mid-air.
	else:
		#IMPORANT NOTE: We only want the players x-velocity to increase when they just touched the ground AND hit the ->
		#-> jump button, so we need to prevent them from gaining speed otherwise (i.e., wall-climbing or in mid-air).
		#accBunnyHop = false
		bunny_fired = false
	
	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept"):
		#hud_RTL.text = str(frame_check)
		frame_check = 0
		#if(jump_token == 1 && wallTouched == false && get_slide_collision_count() != 0 && get_slide_collision(0).get_collider().has_meta("is_wallrunable") == true && get_slide_collision(0).get_collider().get_meta("is_wallrunable") == false ):
			#wallTouched = true
		if(jump_token < 0 && wallTouched == false):
			allowWallJump = false
		elif jump_token > 0 && !is_wallrunning:
			jump_token -= 1;
			land_audio = true;
			velocity.y = JUMP_VELOCITY
			#IMPORTANT NOTE: Without the check in the `if-statement` below to see if `accBunnyHop` is `false` the player would be able ->
			#-> to infinitely gain speed while bunny-hopping because `spd = bs_spd` is never ran when `accBunnyHop = true`. Basically what ->
			#-> this means is that unlike the `BUNNY_SPEED_MULT` variable constant, there is no cap on how many times this `spd += 1` in ->
			#-> the `if-statement` below can run.
			if jump_token == 1 && accBunnyHop == false:
				spd += 1.0
			audio_s_player.stream = load("res://snd_effects/player/wall_grab_option_3.wav");
			audio_s_player.pitch_scale = randf_range(0.9,1.1);
			audio_s_player.play()
			if jump_token < 2 :
				is_wall_run_jumping = 0
	
	#if is_on_floor():
		#spd = bs_spd
		#wall_run_t = 0
		#is_wall_run_jumping = 0
		#jump_token = 2;
		#consecWallJumps = 0
		#collisionInst = null
		#wallTouched = false
		#allowWallJump = true
		#if land_audio :
			##i would turn the below into a function since you're repeating it 
			#land_audio = false
			#step_timer = 0;
			#stp_audio_player.pitch_scale = randf_range(0.7,1.3);
			#stp_audio_player.play()
	##NOTE: This `if-statement` allows for the player to do wall jumps on "non-sliding" walls up to a certain ->
	##-> number of wall jumps (currently `2`).
	#elif(is_on_floor() == false && get_slide_collision_count() != 0 && get_slide_collision(0).get_collider().has_meta("is_wallrunable") == true && get_slide_collision(0).get_collider().get_meta("is_wallrunable") == false && consecWallJumps < 2 && is_wallrunning == false && get_slide_collision(0).get_collider_id() != collisionInst && mantling == false):
		#if(wallTouched == false && jump_token == 0):
			#allowWallJump = false
			#jump_token -= 1
		#else:
			#wallTouched = true
			#collisionInst = get_slide_collision(0).get_collider_id()
			#consecWallJumps += 1
			##NOTE: I re-assign the `jump_token` variable to `1` instead of doing `jump_token += 1` because it ->
			##-> prevents the double jump AND the wall jump from being used (prevents the three jump up a single ->
			##-> wall, allowing players to get to places they shouldn't). Another way to put it is, you either ->
			##-> double jump OR you wall jump, not a mix of the two.
			#jump_token = 1
			##print("I jumped!")
			#hud_RTL.text = str(get_slide_collision(0).get_collider_id())
	#
	## Handle Jump.
	#if Input.is_action_just_pressed("ui_accept"):
		##if(jump_token == 1 && wallTouched == false && get_slide_collision_count() != 0 && get_slide_collision(0).get_collider().has_meta("is_wallrunable") == true && get_slide_collision(0).get_collider().get_meta("is_wallrunable") == false ):
			##wallTouched = true
		#if(jump_token < 0 && wallTouched == false):
			#allowWallJump = false
		#if jump_token > 0 && !is_wallrunning:
			#jump_token -= 1;
			#land_audio = true;
			#velocity.y = JUMP_VELOCITY
			#if jump_token == 1 :
				#spd += 1
			#audio_s_player.stream = load("res://snd_effects/player/wall_grab_option_3.wav");
			#audio_s_player.pitch_scale = randf_range(0.9,1.1);
			#audio_s_player.play()
			#if jump_token < 2 :
				#is_wall_run_jumping = 0
					#
	
	
	#crouching
	if Input.is_action_pressed("crouch") :
		p_collider.scale.y -= crouch_speed * delta;
		head.position.y -= crouch_speed * delta;
		spd = bs_spd - ((bs_spd*spd_crch_mod) * int(is_on_floor()));
	elif !ceil_too_low :
		p_collider.scale.y += crouch_speed * delta;
		head.position.y += crouch_speed * delta;
	p_collider.scale.y = clamp(p_collider.scale.y,crouch_height,default_height)
	head.position.y = clamp(head.position.y,head_default-0.5,head_default)
	
	if not is_on_floor():
		if !on_ladder :
			velocity.y -= fall * delta
		
	if not is_on_wall():
		wall_run_t = 0


	# sptin control
	if Input.is_action_pressed("duck") && Input.is_action_pressed("forward"):
		sprint_spd = sprint_mod
		camera.fov = lerp(camera.fov,fov_sprint,0.1);
		if is_on_floor() && spd < bs_spd + sprint_spd :
			spd += sprint_spd
	else:
		camera.fov = lerp(camera.fov,fov_default,0.1);
		sprint_spd = 0
		sprint = false
		
	# Handle Ledge Grab
	var result1 = ray_upper.get_collider()
	var result2 = ray_lower.get_collider()
	mantling = false
	
	if result1 == null and result2 != null:
		if Input.is_action_pressed("forward") :
			if !is_on_floor() :
				if !Input.is_action_pressed("crouch") :
					velocity.y = JUMP_VELOCITY
					mantling = true

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	if !is_wallrunning :
		if(bookState == "opened" && journalLocked == true && Input.is_action_pressed("left")):
			#bookState = "closed"
			pageLeft.emit()
		elif(bookState == "opened" && journalLocked == true && Input.is_action_pressed(("right"))):
			#bookState = "closed"
			pageRight.emit()
		else:
			var input_dir = Input.get_vector("left", "right", "forward", "back")
			direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
			p_normal = direction
	
	if can_wall_run :
		wall_run()
		process_wall_run_rotation(delta)

	
	if is_wallrunning and Input.is_action_just_pressed("ui_accept") :
		audio_s_player.stream = load("res://snd_effects/player/wall_grab_option_3.wav");
		audio_s_player.pitch_scale = randf_range(0.9,1.1);
		audio_s_player.play()
		
		is_wall_run_jumping += 1
		velocity.y = wall_jump_y_velocity
		jump_token = 1;
		
		if side == "LEFT" :
			wall_jump_dir = global_transform.basis.x * wall_jump_h_power
		if side == "RIGHT" :
			wall_jump_dir = -global_transform.basis.x * wall_jump_h_power
			
		wall_jump_dir *= wall_jump_factor
	
	if is_wall_run_jumping > 0:
		if is_wall_run_jumping < 30 :
			is_wall_run_jumping += 1;
			direction = (direction * (1- wall_jump_factor)) + wall_jump_dir
			if spd < wall_run_spd :
				spd = wall_run_spd + sprint_mod

	if on_ladder :

		is_wall_run_jumping = 0
		is_wallrunning = false
		var look_mod = 1 + abs(camera.global_transform.basis.z.y);
		var forward_vec = Vector3.FORWARD
		var right_vec = Vector3.RIGHT
		var forward = Vector3()
		var right = Vector3()

		# in the function before you move things
		var basis = camera.global_transform.basis
		var sub_spd = int(Input.is_action_pressed("forward")) - int(Input.is_action_pressed("back")) 
		var sub_spd_r = int(Input.is_action_pressed("right")) - int(Input.is_action_pressed("left")) 
		var b_spd = bs_spd*0.5
		forward = basis * forward_vec * sub_spd 
		right = basis * right_vec * sub_spd_r 
		velocity = (forward + right) * (b_spd * look_mod)
		
	else:
		if is_on_floor() :
			if direction:
				velocity.x = direction.x * spd
				velocity.z = direction.z * spd
			else:
				velocity.x = move_toward(velocity.x, 0, spd)
				velocity.z = move_toward(velocity.z, 0, spd)
		elif(is_wallrunning == true):
			#spd = 0.0
			#playerLookVelocGain = 0
			#NOTE: This next part is how the player will gain speed when looking down while wall running, and lose ->
			#-> speed when looking up while wall running.
			#NOTE: We multiply the `camera.rotation.x` instance variable by `2` so that it has a little more ->
			#-> affect on the speed.
			#NOTE: We also want to be able to tell if it is a negative or positive direction that player is ->
			#-> looking because we want to accelerate faster than we deccelerate to make the movement feel good ->
			#-> and like you are picking up speed by going up and down.
			#IMPORTANT NOTE: We make it the negation (`-`) of the cameras rotation because a positive rotation ->
			#-> is when the player is looking up. So to make this positive rotation take away from the player's ->
			#-> `wall_run_x_vec` velocity we have to negate it.
			#if(camera.rotation_degrees[0] <= 3.0 && camera.rotation_degrees[0] > 0.0 && spd <= 20.0):
				#hud_RTL.text = str("");
				#spd += camera.rotation_degrees[0] * 1/90
				#spd += camera.rotation_degrees[2] * 1/90
			if(camera.rotation_degrees[0] <= 0.0 && spd < 15.0):
				#hud_RTL.text = str("");
				spd += -camera.rotation_degrees[0] * 1/10
				
				if(camera.rotation_degrees[0] == 0.0):
					spd += 0.9
				elif(camera.rotation_degrees[2] < 0.0):
					spd += -camera.rotation_degrees[2] * 1/10
				else:
					spd += camera.rotation_degrees[2] * 1/10
			elif(camera.rotation_degrees[0] > 0.0 && spd > 3.0):
				#hud_RTL.text = str("");
				spd += -camera.rotation_degrees[0] * 1/1000
				
				if(camera.rotation_degrees[2] < 0.0):
					spd += camera.rotation_degrees[2] * 1/1000
				else:
					spd += -camera.rotation_degrees[2] * 1/1000
			elif(spd <= 3.0):
				#hud_RTL.text = str("YOURE TOO SLOW");
				spd += 3
			elif(spd >= 15.0):
				#hud_RTL.text = str("YOURE TOO FAST");
				spd += -3
			#else:
				#hud_RTL.text = str("ERROR CATCH: Rotation not found");
				#spd += -0.01
				
			#spd += playerLookVelocGain
			#print(camera.rotation_degrees)
			direction = direction.normalized()
			#NOTE: Changed the `delta` argument for the `move_toward()` instance function from `0.5` to `1`. This ->
			#-> is to make transitioning smoother from one wall instance to another.
			#velocity.x = move_toward(velocity.x,direction.x * spd,1.0);
			#velocity.z = move_toward(velocity.z,direction.z * spd,1.0);
			var newVelocity = Vector3(direction.x * spd, direction.y, direction.z * spd)
			velocity = velocity.move_toward(newVelocity, 1)
		else:
			if direction :
				velocity.x = move_toward(velocity.x,direction.x*spd,0.5);
				velocity.z = move_toward(velocity.z,direction.z*spd,0.5);

	if !in_dialogue :
		if !fog_fade :
			move_and_slide()
			if p_normal.x + p_normal.y + p_normal.z != 0 :
				if is_on_floor() || is_wallrunning || on_ladder:
					step_timer += (spd / bs_spd) + (sprint_spd*0.5);
	
	# position drop shadow
	drop_shadow.global_position.y = ray_shadow.get_collision_point().y + 0.01
	drop_shadow.global_position.x = global_position.x
	drop_shadow.global_position.z = global_position.z
	#hud_RTL.text = str(drop_shadow.global_position.y)
	#drop_shadow.look_at(ray_shadow.get_collision_point() + ray_shadow.get_collision_normal(),Vector3.UP)
	drop_shadow.rotate_y(0.01)
	
	#$Decal.global_position.x = global_position.x
	#$Decal.global_position.z = global_position.z
	
	#hud_RTL.text = str(spd)
	#hud_RTL.text = str(BUNNY_SPEED_MULT)
	#var debug = rad_to_deg(Vector2(p_normal.x,p_normal.z).angle())
	#var debug1 = wrapf((debug + 90) *-1,-180,180)
	#var debug2 = wrapf((rotation_degrees.y + 90) *-1,-180,180)
	#hud_RTL.text = str(spd); ##str(camera.rotation_degrees)
	#$RichTextLabel.text = str(Vector2(velocity.x,velocity.z).angle()) + " , " + str(Vector2(direction.x,direction.z).angle())

	
	







func _on_main_set_particle(type):
	if type == 0 :
		part_rain.visible = true
		part_m_snow.visible = false
	if type == 1 :
		part_rain.visible = false
		part_m_snow.visible = true


func _on_timer_timeout():
	shake_strength = 1.5
	cam_shake = true
	timer_shake.start()


func _on_timer_timeout_player():
	camera.h_offset = 0.0
	camera.v_offset = 0.0
	cam_shake = false


func _on_unstuck_pressed():
	position = spwn_point.global_position
	rotation.y = spwn_point.rotation.y
	pause = !pause
	blink_anim.play()
