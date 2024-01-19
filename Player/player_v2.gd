extends CharacterBody3D

const JUMP_VELOCITY = 12
var wall_jump_y_velocity = 14
var mouseSensibility = 600
var mouse_relative_x = 0
var mouse_relative_y = 0


@onready var ray_upper = $Head/Upper_Check
@onready var ray_lower = $Head/Lower_Check
@onready var ray_shadow = $D_Shad_Check
@onready var camera = $Head/Camera3D
@onready var head = $Head
@onready var drop_shadow = $Drop_Shadow
@onready var stp_audio_player = $footsteps_1
#@onready var gun_anim = $"Head/Camera3D/Steampunk Rifle/AnimationPlayer"
#@onready var gun_barrel = $"Head/Camera3D/Steampunk Rifle/RayCast3D"
#@onready var gun_fire_aud =  $"Head/Camera3D/Steampunk Rifle/fire_audio_1"
#@onready var gun_flash = $"Head/Camera3D/Steampunk Rifle/OmniLight3D"
@onready var gun_anim = $"Head/Camera3D/FinalShottyVolver/AnimationPlayer2"
@onready var gun_barrel = $"Head/Camera3D/FinalShottyVolver/RayCast3D"
@onready var gun_fire_aud =  $"Head/Camera3D/FinalShottyVolver/fire_audio_1"
@onready var gun_flash = $"Head/Camera3D/FinalShottyVolver/OmniLight3D"

#bullets 
var bullet = load("res://Models/weapons/bullet_test_1.tscn")
var instance

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = 30
var fall = 30
var bs_spd = 2.5
var wall_run_spd = 12
var spd = 2.5
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
var wall_climb_strength = 2 #export me
var mantling = false
var sprint_mod = 0
var sprint_spd = 2.5;
var stagger_force = 16.0
var flash_time = 0;

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

signal player_hit

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED #captures mouse inside the screenspace

func _process(_delta):
	if step_timer > 30 :
		step_timer = 0;
		stp_audio_player.pitch_scale = randf_range(0.7,1.3);
		stp_audio_player.play()

func _input(event):
#Handle escape quit function
	if event.is_action_pressed("escape"):
		get_tree().quit()
	
	
#Handle camera look / aim
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

func _hit(dir):
	emit_signal("player_hit");
	velocity += dir * stagger_force

func _physics_process(delta):
	# Add the gravity.

	#sprint modifier
	if Input.is_action_pressed("duck"):
		sprint_mod = sprint_spd;
	else :
		sprint_mod = 1;
		

	#pretty sure there's a better way to do this 
	if flash_time > 0 :
		gun_flash.visible = true
		flash_time -= 1
	else :
		gun_flash.visible = false
		
	#gun firing behavior 
	#would it be better to put audio and animates into a script in the gun instead?
	if Input.is_action_pressed("shoot"):
		if !gun_anim.is_playing():
			flash_time = 5
			#gun_anim.play("shoot_test_1")
			gun_anim.play("fire_revolver_1")
			#gun_anim.play("CylrinderAction")
			gun_fire_aud.play()
			instance = bullet.instantiate()
			instance.position = gun_barrel.global_position
			instance.transform.basis = gun_barrel.global_transform.basis
			get_parent().add_child(instance)

	if is_on_floor():
		spd = bs_spd+sprint_mod;
		wall_run_t = 0
		is_wall_run_jumping = false
	
	if not is_on_floor():
		velocity.y -= fall * delta
		
	if not is_on_wall():
		wall_run_t = 0

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept"):
		if is_on_floor():
			velocity.y = JUMP_VELOCITY
		
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
	
	if p_normal.x + p_normal.y + p_normal.z != 0 :
		step_timer += 1;
	
	
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
			spd = wall_run_spd

	
	if direction:
		velocity.x = direction.x * spd
		velocity.z = direction.z * spd
	else:
		velocity.x = move_toward(velocity.x, 0, spd)
		velocity.z = move_toward(velocity.z, 0, spd)

	move_and_slide()
	
	# position drop shadow
	drop_shadow.global_position.y = ray_shadow.get_collision_point().y + 0.01
	drop_shadow.global_position.x = global_position.x
	drop_shadow.global_position.z = global_position.z
	$RichTextLabel.text = str(drop_shadow.global_position.y)
	#drop_shadow.look_at(ray_shadow.get_collision_point() + ray_shadow.get_collision_normal(),Vector3.UP)
	drop_shadow.rotate_y(0.01)
	
	#$Decal.global_position.x = global_position.x
	#$Decal.global_position.z = global_position.z
	
	var debug = rad_to_deg(Vector2(p_normal.x,p_normal.z).angle())
	var debug1 = wrapf((debug + 90) *-1,-180,180)
	var debug2 = wrapf((rotation_degrees.y + 90) *-1,-180,180)
	$RichTextLabel.text = str(step_timer); ##str(camera.rotation_degrees)
	#$RichTextLabel.text = str(Vector2(velocity.x,velocity.z).angle()) + " , " + str(Vector2(direction.x,direction.z).angle())

	
	
