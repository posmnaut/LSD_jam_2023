extends CharacterBody3D

const JUMP_VELOCITY = 12*0.8
var wall_jump_y_velocity = 14
var mouseSensibility = 600
var mouse_relative_x = 0
var mouse_relative_y = 0
var jump_token = 2;
@onready var ray_upper = $Head/Upper_Check
@onready var ray_lower = $Head/Lower_Check
@onready var ray_shadow = $D_Shad_Check
@onready var camera = $Head/Camera3D
@onready var head = $Head
@onready var drop_shadow = $Drop_Shadow
@onready var stp_audio_player = $footsteps_1
@onready var gun_anim = $"Head/Camera3D/Steampunk Rifle/AnimationPlayer"
@onready var NPC_talk_area = $Area3D;
@onready var Look_Cast = $Head/Look_Cast_NPC
@onready var look_cast_door = $Head/Look_Cast_door
@onready var hud_RTL = $UI/RichTextLabel;
@onready var blink_anim = $UI/MarginContainer/AnimatedSprite2D
@onready var audio_s_player = $AudioStreamPlayer
@onready var fog_color_default
@onready var fog_density_default
@onready var interact_sprite = $UI/MarginContainer/sprite_pointer
@onready var bump_trigger_detect = $Area3D


@export var spwn_point : Node3D
@export var environ_a : WorldEnvironment

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = 30
var fall = 30
var bs_spd = 6
var wall_run_spd = 12
var spd = 6
var p_normal
var wall_run_t = 0 
var direction
var is_wallrunning = false
var side = ""
var wall_jump = false
var is_wall_run_jumping = false
var wall_jump_dir = Vector3.ZERO
var wall_jump_factor = 0.4 #export me
var wall_jump_h_power = 2 #export me
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

var debug1
var debug2

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
	

func _process(delta):
	if step_timer > 30 :
		step_timer = 0;
		stp_audio_player.pitch_scale = randf_range(0.7,1.3);
		stp_audio_player.play()
		
	#close game loop
	#plays anim then pauses then closes
	if close_game :
		if !blink_anim.is_playing() :
			blink_anim.play_backwards();
			
		if blink_anim.frame == 0 || eyes_state_sub_timer > 0:
			blink_anim.set_frame_and_progress(0,0.0);
			eyes_state_sub_timer += 1;
			if eyes_state_sub_timer >= 15 :
				get_tree().quit()
				
	#draw "can interact" icon
	if !in_dialogue && !fog_fade:
		var NPC_check = Look_Cast.get_collider();
		var door_check = look_cast_door.get_collider();
		if NPC_check != null || door_check != null:
			interact_sprite.visible = true
			point_timer += 3
			if point_timer > 359 :
				point_timer = point_timer - 360;
			var _s = (1+sin(deg_to_rad(point_timer))) *0.2;
			interact_sprite.scale.x = 0.75+_s
			interact_sprite.scale.y = 0.75+_s
		else :
			interact_sprite.visible = false
		if NPC_check != null :
			NPC_check.set_meta("face_player", false)
	else :
		interact_sprite.visible = false
		
	#falling fade out behavior
	if fog_fade == true :
		if 	fall_fade == 0 :
			fall_tween = create_tween()
			fall_tween.set_parallel(true)
			fall_tween.tween_property(environ_a.environment, "fog_density", 1.0,3.0)
			fall_tween.tween_property(environ_a.environment, "fog_light_color", fall_color_white,3.0)
			fall_tween.finished.connect(set.bind("fall_fade", 2 ))
			fall_fade = 1
	
		if fall_fade > 1 :
			# this handles position teleportation
			if teleport_point != null :
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
			if NPC_check.has_meta("is_sleep") :
				NPC_check.set_meta("is_sleep",true)
		

func _input(event):
	#Handle escape quit function
	if event.is_action_pressed("escape"):
		close_game = true;
	
	#this is organized terribly, fix it 
	#Handle NPC talk w/ shoot 
	#Handle click trigger
	if Input.is_action_pressed("shoot") && in_dialogue == false:
		if !fog_fade :		
			var NPC_check = Look_Cast.get_collider();
			var click_check = look_cast_door.get_collider();
			if NPC_check != null :
				var meta_check = NPC_check.get_meta("dialogue") 
				var op_audio = NPC_check.get_meta("opener_audio")
				var talk_timer = NPC_check.get_meta("talk_timer")
				var is_asleep  = NPC_check.get_meta("fully_sleep")
				NPC_check.set_meta("face_player", true)
				if !is_asleep :
					Dialogic.start(meta_check)
					in_dialogue = true;
					if op_audio != null :
						if !audio_s_player.is_playing() :
							if talk_timer == false :
								audio_s_player.stream = op_audio;
								audio_s_player.play();
								NPC_check.set_meta("talk_timer",true);
			
			if click_check !=null :
				teleport_point = click_check.get_parent().target_point;
				fog_fade = true

	
#Handle camera look / aim
	if fog_fade == false :
		if event is InputEventMouseMotion:
			rotation.y -= event.relative.x / mouseSensibility 
			camera.rotation.x -= event.relative.y / mouseSensibility
			camera.rotation.x = clamp(camera.rotation.x,deg_to_rad(-90),deg_to_rad(90))
			mouse_relative_x = clamp(event.relative.x,deg_to_rad(-50),deg_to_rad(50))
			mouse_relative_y = clamp(event.relative.y,deg_to_rad(-50),deg_to_rad(50))
		
func wall_run():
	if is_on_wall() && Input.is_action_pressed("forward") && Input.is_action_pressed("duck") && !is_on_floor() && !mantling:
		var normal = get_wall_normal()
		var collision = get_slide_collision(0)
		var is_wallrunable = collision.get_collider().get_meta("is_wallrunable") 
		
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
			velocity.y += camera.rotation.x * wall_climb_strength
			direction = wall_run_dir
			side = get_side(collision.get_position())
			wall_run_x_rot = rad_to_deg(Vector2(wall_run_dir.x,wall_run_dir.z).angle())
			wall_run_x_vec = Vector2(wall_run_dir.x,wall_run_dir.z)
			is_wallrunning = true
			is_wall_run_jumping = false
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
		spd = bs_spd
		wall_run_t = 0
		is_wall_run_jumping = false
		jump_token = 2;
		if land_audio :
			#i would turn the below into a function since you're repeating it 
			land_audio = false
			step_timer = 0;
			stp_audio_player.pitch_scale = randf_range(0.7,1.3);
			stp_audio_player.play()
	
	if not is_on_floor():
		velocity.y -= fall * delta
		
	if not is_on_wall():
		wall_run_t = 0


	# sptin control
	if Input.is_action_pressed("duck") :
		sprint_spd = sprint_mod
		camera.fov = lerp(camera.fov,fov_sprint,0.1);
		if is_on_floor() && spd < bs_spd + sprint_spd :
			spd += sprint_spd
	else:
		camera.fov = lerp(camera.fov,fov_default,0.1);
		sprint_spd = 0
		sprint = false

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept"):
		if jump_token > 0 && !is_wallrunning :
			jump_token -= 1;
			land_audio = true;
			velocity.y = JUMP_VELOCITY
			spd += 2
		
	# Handle Ledge Grab
	var result1 = ray_upper.get_collider()
	var result2 = ray_lower.get_collider()
	mantling = false
	
	if result1 == null and result2 != null:
		if Input.is_action_pressed("forward") and !is_on_floor():
			velocity.y = JUMP_VELOCITY
			mantling = true

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "forward", "back")
	direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	p_normal = direction
	
	
	wall_run()
	
	process_wall_run_rotation(delta)

	
	if is_wallrunning and Input.is_action_just_pressed("ui_accept") :
		
		is_wall_run_jumping = true
		velocity.y = wall_jump_y_velocity
		
		if side == "LEFT" :
			wall_jump_dir = global_transform.basis.x * wall_jump_h_power
		if side == "RIGHT" :
			wall_jump_dir = -global_transform.basis.x * wall_jump_h_power
			
		wall_jump_dir *= wall_jump_factor
	
	if is_wall_run_jumping :
		direction = (direction * (1- wall_jump_factor)) + wall_jump_dir
		if spd < wall_run_spd :
			spd = wall_run_spd + sprint_mod

	
	if direction:
		velocity.x = direction.x * spd
		velocity.z = direction.z * spd
	else:
		velocity.x = move_toward(velocity.x, 0, spd)
		velocity.z = move_toward(velocity.z, 0, spd)

	if !in_dialogue :
		if !fog_fade :
			move_and_slide()
			if p_normal.x + p_normal.y + p_normal.z != 0 :
				if is_on_floor() || is_wallrunning :
					step_timer += 1+(sprint_spd*0.5);
	
	# position drop shadow
	drop_shadow.global_position.y = ray_shadow.get_collision_point().y + 0.01
	drop_shadow.global_position.x = global_position.x
	drop_shadow.global_position.z = global_position.z
	hud_RTL.text = str(drop_shadow.global_position.y)
	#drop_shadow.look_at(ray_shadow.get_collision_point() + ray_shadow.get_collision_normal(),Vector3.UP)
	drop_shadow.rotate_y(0.01)
	
	#$Decal.global_position.x = global_position.x
	#$Decal.global_position.z = global_position.z
	
	#var debug = rad_to_deg(Vector2(p_normal.x,p_normal.z).angle())
	#var debug1 = wrapf((debug + 90) *-1,-180,180)
	#var debug2 = wrapf((rotation_degrees.y + 90) *-1,-180,180)
	hud_RTL.text = str(step_timer); ##str(camera.rotation_degrees)
	#$RichTextLabel.text = str(Vector2(velocity.x,velocity.z).angle()) + " , " + str(Vector2(direction.x,direction.z).angle())

	
	
