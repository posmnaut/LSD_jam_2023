GDPC                 �                                                                         P   res://.godot/exported/133200997/export-3070c538c03ee49b7677ff960a3f5195-main.scn�     �      ���%	}�G����    T   res://.godot/exported/133200997/export-c48983f56782aa5ce9bcacbe3367d940-Block.scn           S      +�-�4�{�k�?�Է�    T   res://.godot/exported/133200997/export-d267b47f7e81a3258979164d56d0d9c2-player.scn  $      �      �a�%{�
9K\����    ,   res://.godot/global_script_class_cache.cfg                 ��Р�8���8~$}P�    P   res://.godot/imported/d_shadow_1.png-ae09af55cb25d1a100c94410086974d2.s3tc.ctex �4      d�      MZ�;3��S�u���j,    D   res://.godot/imported/icon.svg-218a8f2b3041327d8a5756f3a245f83b.ctex`�      ^      2��r3��MgB�[79       res://.godot/uid_cache.bin  �.     �       iy=��n��>�δ        res://Objects/Block.tscn.remap  @     b       �T���~u���B�3�`       res://Player/player.gd  �      �      ����NS%���.,��       res://Player/player.gdshader       �      <������t/6��T        res://Player/player.tscn.remap  �     c       ��!��5a�j��s>       res://icon.svg  �     N      ]��s�9^w/�����       res://icon.svg.import   �     �       ��X�����E�,0���       res://main.gdshader �     �      <������t/6��T       res://main.tscn.remap         a       �J�Sw� ������       res://project.binary�/     �      ���2+��*7���T    $   res://textures/d_shadow_1.png.import`�      �       �D�gJ��r/�齮D�/    list=Array[Dictionary]([])
2�I�PRSRC                     PackedScene            ��������                                                  resource_local_to_scene    resource_name    custom_solver_bias    margin    size    script    lightmap_size_hint 	   material    custom_aabb    flip_faces    add_uv2    uv2_padding    subdivide_width    subdivide_height    subdivide_depth 	   _bundled           local://BoxShape3D_a66xn �         local://BoxMesh_r1yry 	         local://PackedScene_wh12r !         BoxShape3D             BoxMesh             PackedScene          	         names "         Block    disable_mode    metadata/is_wallrunable    StaticBody3D    CollisionShape3D    shape    MeshInstance3D    mesh    	   variants                                            node_count             nodes        ��������       ����                                  ����                           ����                   conn_count              conns               node_paths              editable_instances              version             RSRC�(�pk�[m�f�extends CharacterBody3D

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

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = 30
var fall = 30
var bs_spd = 5.0
var wall_run_spd = 12
var spd = 5.0
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

var wall_run_angle = 15 #export me 
var wall_run_current_angle = 0
var wall_run_x_rot = 0
var wall_run_x_vec = Vector2.ZERO
var wall_run_dir_ex = 0
var dot_ex = 0

var debug1
var debug2

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED #captures mouse inside the screenspace

func _input(event):
#Handle escape quit function
	if event.is_action_pressed("escape"):
		get_tree().quit()
	
	
#Handle camera look / aim
	if event is InputEventMouseMotion:
		rotate_y(- event.relative.x / mouseSensibility) 
		$Head/Camera3D.rotate_x(- event.relative.y / mouseSensibility)
		$Head/Camera3D.rotation.x = clamp($Head/Camera3D.rotation.x,deg_to_rad(-90),deg_to_rad(90))
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

		
	else :
		if wall_run_current_angle > 0 :
			wall_run_current_angle -= delta * 40
			wall_run_current_angle = max(wall_run_current_angle, 0)
		elif wall_run_current_angle < 0 :
			wall_run_current_angle += delta * 40
			wall_run_current_angle = min(wall_run_current_angle, 0)
			
	camera.rotation_degrees.z = wall_run_current_angle


func _physics_process(delta):
	# Add the gravity.

	if is_on_floor():
		spd = bs_spd
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
			
	# position drop shadow
	drop_shadow.global_position.y = ray_shadow.get_collision_point().y+0.01
	drop_shadow.rotate_y(0.01)

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
			spd = wall_run_spd

	
	if direction:
		velocity.x = direction.x * spd
		velocity.z = direction.z * spd
	else:
		velocity.x = move_toward(velocity.x, 0, spd)
		velocity.z = move_toward(velocity.z, 0, spd)

	move_and_slide()
	
	var debug = rad_to_deg(Vector2(p_normal.x,p_normal.z).angle())
	var debug1 = wrapf((debug + 90) *-1,-180,180)
	var debug2 = wrapf((rotation_degrees.y + 90) *-1,-180,180)
	#$RichTextLabel.text = str(velocity)
	#$RichTextLabel.text = str(Vector2(velocity.x,velocity.z).angle()) + " , " + str(Vector2(direction.x,direction.z).angle())

	
	
7~*_�\^7(�3��shader_type canvas_item;

uniform vec4 background_color : source_color;
uniform vec4 shadow_color : source_color;
// Currently pixels always in application size, so zooming in further wouldn't increase the size of the dropdown
// but changing that would also be relatively trivial
uniform vec2 offset_in_pixels;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void fragment() {
	
	// Read screen texture
	vec4 current_color = textureLod(SCREEN_TEXTURE, SCREEN_UV, 0.0);
	
	// Check if the current color is our background color
	if (length(current_color - background_color) < 0.01) {
		
		vec4 offset_color = textureLod(SCREEN_TEXTURE, SCREEN_UV - offset_in_pixels * SCREEN_PIXEL_SIZE, 0.0);
		
		// Check if at our offset position we have a color which is not the background (meaning here we need a shadow actually)
		if (length(offset_color - background_color) > 0.01) {
			// If so set it to our shadow color
			current_color = shadow_color;
		}
	}
	
	COLOR = current_color;
}�מ�qt~�V��Mq	\RSRC                     PackedScene            ��������                                            U      resource_local_to_scene    resource_name    lightmap_size_hint 	   material    custom_aabb    flip_faces    add_uv2    uv2_padding    radius    height    radial_segments    rings    script    custom_solver_bias    margin    points    render_priority 
   next_pass    transparency    blend_mode 
   cull_mode    depth_draw_mode    no_depth_test    shading_mode    diffuse_mode    specular_mode    disable_ambient_light    vertex_color_use_as_albedo    vertex_color_is_srgb    albedo_color    albedo_texture    albedo_texture_force_srgb    albedo_texture_msdf    heightmap_enabled    heightmap_scale    heightmap_deep_parallax    heightmap_flip_tangent    heightmap_flip_binormal    heightmap_texture    heightmap_flip_texture    refraction_enabled    refraction_scale    refraction_texture    refraction_texture_channel    detail_enabled    detail_mask    detail_blend_mode    detail_uv_layer    detail_albedo    detail_normal 
   uv1_scale    uv1_offset    uv1_triplanar    uv1_triplanar_sharpness    uv1_world_triplanar 
   uv2_scale    uv2_offset    uv2_triplanar    uv2_triplanar_sharpness    uv2_world_triplanar    texture_filter    texture_repeat    disable_receive_shadows    shadow_to_opacity    billboard_mode    billboard_keep_scale    grow    grow_amount    fixed_size    use_point_size    point_size    use_particle_trails    proximity_fade_enabled    proximity_fade_distance    msdf_pixel_range    msdf_outline_size    distance_fade_mode    distance_fade_min_distance    distance_fade_max_distance    size    subdivide_width    subdivide_depth    center_offset    orientation 	   _bundled       Script    res://Player/player.gd ��������
   Texture2D    res://textures/d_shadow_1.png :��^~      local://CapsuleMesh_tnk60 8      #   local://ConvexPolygonShape3D_csmiy T      !   local://StandardMaterial3D_ysqe2 
         local://QuadMesh_x8e4q h
         local://PackedScene_3tsfj �
         CapsuleMesh             ConvexPolygonShape3D       #       D6 ��e������<r��>�m�>?�->$?���>��l>$�M���>��>��&?^y�0���G?e_�=�ɹ� �.�*S�>�&�>6�'�?������A�W?���Ppɾ�/��z��b�>.�?\�M>�U�=m:z?��=����'�y�[_��\M>9)��$���=��o?�-�<�����?"��>K�%"��o��>�k�>h���G�>���=�$?�\��ˡվ:"?�~��j��(��=6�� ;��t�h?�vZ=���Wva�%?R>���> g��s�U4�>T_?�� ��/�>ؼ�������>J
�>n��B�Y= `?y?�>�@�5B����>�:ǽ�HH�L�˾�yƾE�����>��׆�Ǿ         StandardMaterial3D                                           �?                  	   QuadMesh             PackedScene    T      	         names "         Player    floor_stop_on_slope    script    CharacterBody3D    MeshInstance3D 
   transform    visible    cast_shadow    mesh    CollisionShape3D    shape    Head    Node3D 	   Camera3D    Upper_Check    target_position    debug_shape_custom_color 
   RayCast3D    Lower_Check    RichTextLabel    offset_right    offset_bottom    D_Shad_Check    Drop_Shadow    material_override    gi_mode    	   variants                             �?              �?              �?    C��?                                  �?              �?              �?    ��?         �?              �?              �?    ?;                 ��     �?          �?     �?              �?              �? �#&qN� �/    �BD    ��C     �?              �?              �?      �?             ��         @@            ���  �?      @�1�;�    Y�>                                   node_count    
         nodes     t   ��������       ����                                  ����                                        	   	   ����         
                        ����                          ����                     ����                  	                    ����      
                           ����                                 ����                                 ����                                           conn_count              conns               node_paths              editable_instances              version             RSRC�v����!e�1GST2   �   �     �����                � �                 ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU I�$IB���a   U I�$IB���a   U I�$IB���a   U I�$IB���a   U I�$IB���a   U I�$IB&��a             ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU I�$I���a   T I�$!I���a  TU IB�$I���a UUU           UUUUI�$I��    UUUUI�$IB�    UUUUI�$IB�    UUUUI�$IB�    UUUUI�$IB�    UUUUI�$IB�    UUUUI�$IB�    UUUUI�$I�$    UUUU IB�$I���a UUU I�$$I���a UU I�$LB���a  U          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU I��!I���a @TU 	I�$I���aPUUUI�$IH�    UUUUI��$I�    UUUUIb۶�m    UUUUI�$$I�    UUUUI�$�mo    UUUUIb۶�m    UUUUIb۶�m    UUUUIb۶�m    UUUUIb۶�m    UUUUIb۶�m    UUUUIb'��m    UUUUI�$�=�    UUUUvb۳�m    UUUUIb;���    UUUUI�$dB�    UUUUI�$IB&    UUUU IB&$I���a UU I�$LB2��a            ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU I��!I���a @TU �m۶mo��aTUUUI�Ķm{    UUUU�m���m    UUUUI۶�m    UUUUI�Ķ�m    UUUUIl�$II    UUUUI�6IJ    UUUUIb�$)I    UUUU���-II    UUUUIb�$)I    UUUUIb�$)I    UUUUIb�$)I    UUUUIb�$)I    UUUUO��m+�    UUUUIb�$)I    UUUU�C�$)I    UUUUIb;�-�    UUUUvb�$-�    UUUUI�$���    UUUUNb۶��    UUUUI�$dB�    UUUU dB�$I���aUUU I�$LB2��a            ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU I�$I����a   @ 	�$I���aPTUUI��!I�    UUUU�m�6IR    UUUU�m�&IJ    UUUU���mIR    UUUU���-IJ    UUUU
��n�M    UUUU�o�m�I    UUUU�o�m'I    UUUUIn�m'I    UUUU	I��m+I    UUUU	Ib�$9I    UUUU	�o�$)I    UUUU	Ob�$)I    UUUU	Ib�d+m    UUUU	I��m+i    UUUUIb�m+i    UUUUOb�m-m    UUUUOb�m�m    UUUU	O��d+�    UUUUO��l+�    UUUUNb�$-�    UUUUNbۤ-�    UUUU�cۛ�m    UUUUI�$$C�    UUUU LB2$I���aUU I�$LB&��a            ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU I�$	���a  PT �m۶m{��aTUUU�۶go    UUUU�m�6IJ    UUUU���-YR    UUUU	���-IJ    UUUU�m�-�M    UUUU�m�-�I    UUUU
��%7	    UUUU��%'    UUUUIr�%'    UUUUI��-)	    UUUUI��%)    UUUUI��%)    UUUUI��$	     UUUUI��$	     UUUUIb�dH    UUUUIb�dI    UUUUIb�#	@    UUUUI��di    UUUUIb�dm    UUUU	���	h    UUUUb�l��    UUUUb�k-m    UUUU	O�?l/�    UUUU���l/�    UUUUvb;�-�    UUUUvb;���    UUUUI�$LB2    UUUU I�$dB2��a           ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU I��	���a @PTI�$I��    UUUU�m�6iR    UUUUI��6iR    UUUU	���v�N    UUUU�}�.IN    UUUU	�}�.�	    UUUU�}�%7	    UUUU��-�	    UUUUI~�%�	    UUUUI��-�	    UUUU!I~�%7    UUUU$I~�$)	    UUUU&Ir�$)    UUUU'Ib�$)     UUUU(Ir�$)    UUUU(Ib�$	I    UUUU'Ib�$	@    UUUU&Ib�$	I    UUUU$IR�$I    UUUU!Ib�ci    UUUUOR�cm    UUUUR�cm    UUUUOR�l�    UUUUOR�c�    UUUU	R�c�    UUUU���c��    UUUU	�S�k��    UUUUvB;�-�    UUUUIb'���    UUUUI�$dB2    UUUU LB&$C���aU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU I�$I����a  @P �m۶go��aTUUU�m�6iR    UUUU��&EJ    UUUU
���w�N    UUUU���.WN    UUUUɟ�.W
    UUUUI��.W
    UUUU���.�    UUUU#��%G	    UUUU)��%�	    UUUU.�o��6    UUUU2#�o��&    UUUU6&Ir�$'    UUUU9)Ir�$)    UUUU:+Ib��     UUUU;,Ib��     UUUU;,Ib�	     UUUU:*Ib�	     UUUU9)Ib�$	H    UUUU6&Ib�#H    UUUU2"OR�#H    UUUU.R�#h    UUUU)R�cm    UUUU#��c�    UUUUR�c�    UUUU~R�c��    UUUU~��k�    UUUU���c�    UUUU���c��    UUUU�S����    UUUUvB;�-�    UUUUNb'�3�    UUUU LB&$I���aUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU I�$I����a   @ �m۶g{��aTUUU�m�6iR    UUUUɛ��R    UUUU
�}�v�N    UUUU�{���	    UUUU�{�.W
    UUUU���.W    UUUU#�}���	    UUUU+�}���	    UUUU3#���.�	    UUUU:)I~�-7    UUUUA.��%7    UUUUG4I~�%7    UUUUL8I~�$'    UUUUP<Ir�$'    UUUUS?Ir�$)     UUUUT@Ib�$	     UUUUT@Ib�$	     UUUUS?Ib�$	@    UUUUQ<Ib�#	H    UUUUM8OR�H    UUUUH3R�i    UUUUB.��#i    UUUU;)R�#m    UUUU4#��c�    UUUU,~��h    UUUU%���c�    UUUU~��c�    UUUU���[�    UUUU	~��b�    UUUU���c��    UUUU}�>d/�    UUUUvB;�-�    UUUUNb'�3�    UUUU LB&$C���aU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU 	��!���aPPTT�۱go    UUUU���1iS    UUUU
���w�N    UUUU�{w.U
    UUUUɛ�o�    UUUU�{�.U
    UUUU'�}�.W
    UUUU1!��.�	    UUUU;)�}���	    UUUUF1�}�-�	    UUUUP9��-�	    UUUUYA��%7	    UUUUaII~�%7    UUUUgOI~��&    UUUUlTIb��&     UUUUoXIb�$'     UUUUqZIb�$	     UUUUqZIb�$	     UUUUpXIb�	     UUUUmUIb�#	@    UUUUhOO��	H    UUUUbIO��#h    UUUUZB��h    UUUUQ:��#i    UUUUH3~R�cm    UUUU>+~��c�    UUUU5#~R�c�    UUUU+~��b�    UUUU"���c�    UUUU~��c��    UUUU
u��c��    UUUU~�>���    UUUU	~R?���    UUUUvB;�-�    UUUUNb'v2;    UUUU I�$dB2��a           ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU I��I����a @@PI��	��    UUUU��6iS    UUUU	���w�N    UUUU���7�N    UUUU��.U    UUUU�{�.U
    UUUU)�{�.U
    UUUU4#�{�.U
    UUUUA-�{�.�	    UUUUN8�}�.�	    UUUU[C�}���	    UUUUhM�}�-�	    UUUUsX��%�	    UUUU}a���6    UUUU�i�o��&    UUUU�pI~��&    UUUU�uIb��&     UUUU�xIb��     UUUU�xIb��     UUUU�vIb�	     UUUU�qIR�	@    UUUU�kOR�H    UUUUc��#h    UUUUvZ��#i    UUUUkP��m    UUUU_F~��c�    UUUUS;~���    UUUUG1���c�    UUUU;'���b�    UUUU/~�:b�    UUUU%u��c��    UUUU}��c��    UUUU
���b��    UUUU~B?�/�    UUUU}�>�/�    UUUUNb'���    UUUU �3۳�ٞ�aUUU I�$L�$��a            ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU �۱m{��aPTTU��6iS    UUUUy��/�R    UUUU�{�.�N    UUUU��w7�    UUUU��w/�    UUUU'�{w.U    UUUU4#��.U
    UUUUC.�{���	    UUUUS;�{�.�	    UUUUcI�}���	    UUUUsW�}�.�	    UUUU�d�}���	    UUUU�q�}��	    UUUU�}���6    UUUU���o��&    UUUU��In��&    UUUU��Ib��&     UUUU��Ib��     UUUU��Ib��     UUUU��I���     UUUU��OR�	H    UUUU����	H    UUUU���i    UUUU�t~��i    UUUU�i~��i    UUUUy\~��[�    UUUUjO~��Z�    UUUU\B���[�    UUUUM6~��c�    UUUU?*���b�    UUUU1 u��b�    UUUU%���b��    UUUU}�>���    UUUU
u�>���    UUUU�C?�/�    UUUU}�>�/�    UUUU�3;���    UUUU dB&$C2��a          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU I�$I����a  @@I��	��    UUUU��6eR    UUUU	y��/�R    UUUU	yyw/�    UUUU�w7�    UUUU$�w7�    UUUU1!�w/e
    UUUUB-�{w.e    UUUUS;�{w�T
    UUUUfK�{���	    UUUUy\�{���	    UUUU�m�{���	    UUUU�}�}���	    UUUU���}���	    UUUU���}��6	    UUUU�����6    UUUUŬ�o��&    UUUUɲIb��&     UUUU˶Ib��     UUUU˶Ib��     UUUUʳIR�	@    UUUUǮO��	H    UUUU����h    UUUU��~��i    UUUU�����i    UUUU��~��m    UUUU�t����    UUUU�e���Z�    UUUUrU���Z�    UUUU`F���Z�    UUUUO8u��b�    UUUU?+���b�    UUUU0���b�    UUUU#��:b��    UUUU��>c��    UUUU	��:���    UUUU
~R?���    UUUU�C:�-�    UUUULB&dB&    UUUU I�$LB&��a           ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU 	��	���aPPPT�{�go    UUUUy���R    UUUU��{qwO    UUUU��w1�    UUUUy�w/�    UUUU,yw/e    UUUU<)�w/e    UUUUO8�w/e    UUUUdI�{w�T
    UUUUz\�{w�T
    UUUU�p�{w��	    UUUU���{���	    UUUU���{���	    UUUU¦�}���	    UUUUʹ�}��4    UUUUֿ���6	    UUUU���o��$    UUUU��Ib��&    UUUU��Ib��     UUUU��I���     UUUU��I���     UUUU����	H    UUUU����i    UUUUѸ~��i    UUUUǫ���i    UUUU�����m    UUUU������    UUUU�|����    UUUU�j���Z�    UUUUuX���Z�    UUUUaG���Z�    UUUUN7��:b�    UUUU<)��:b��    UUUU-��:b��    UUUU ��:���    UUUUu�>���    UUUU��>�/�    UUUU���b/�    UUUU�C;�-�    UUUU dB&$C2��a          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU �۶g{��aTTUU��x�o    UUUUy�R/�R    UUUUqwS��    UUUUyw1�    UUUU%��w7�    UUUU5#�w7�    UUUUH2yw/e    UUUU^D�w�d    UUUUuX�yw�d
    UUUU�n�ys�T
    UUUU���ys��	    UUUU���{w��	    UUUUɭ�{���	    UUUUֽ�{���	    UUUU���}��	    UUUU���m��6	    UUUU�����$    UUUU���o��&	    UUUU��Ib��&    UUUU��Ib�	H    UUUU��O��	H    UUUU����	i    UUUU��~��h    UUUU��~��h    UUUU��~���    UUUUϵ����    UUUU������    UUUU������    UUUU����Z�    UUUU�j�3�Z�    UUUUsW���b�    UUUU]D��:b�    UUUUI3���b��    UUUU7$��:b��    UUUU'��:���    UUUU��:���    UUUU	�#�Z��    UUUU
�S?���    UUUU�C:�#�    UUUUL�$dB&    UUUU I�$I�$��a             ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU I��I����a @@@I��	��    UUUU1eS6eJ    UUUU
y��9�R    UUUU
ys7�    UUUUy�w7�    UUUU+yS��    UUUU=*yw/�    UUUUS;ys�d    UUUUlPys/e    UUUU�gyys�d
    UUUU���s�d
    UUUU��yys��	    UUUU˯�{w�T
    UUUU�¹{w��	    UUUU�ѹ����	    UUUU���{���	    UUUU����4    UUUU���m��	    UUUU�����$     UUUU��Ib�$'I    UUUU��I��#)I    UUUU��O��	I    UUUU��~��h    UUUU����m    UUUU������    UUUU������    UUUU������    UUUUӺ����    UUUUĨ���Z�    UUUU�����Z�    UUUU�}�3�Z�    UUUU�f�3�Z�    UUUUlQ�:Z��    UUUUU>��:b��    UUUU@,�3:b��    UUUU.�#:Z��    UUUU�>���    UUUUt�>���    UUUU���/�    UUUU�#:�#�    UUUUv2;�3;    UUUU LB&dB&��a          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU I��	����a@PPP�{�{    UUUUy���R    UUUU��wquO    UUUU��w1    UUUU!yS/�    UUUU1!yS1�    UUUUF1yw7�    UUUU^Dys��    UUUUy\ys��    UUUU�vyS�`
    UUUU��yys�d
    UUUUǪyys�T
    UUUU���ys��	    UUUU�ӹ{w��	    UUUU��y�r��	    UUUU���{���    UUUU��}��4	    UUUU����%�M    UUUU�����%II    UUUU��I��%IR    UUUU��NBҒ(I    UUUU���Ӷ$)I    UUUU������*i    UUUU�����m    UUUU��u���    UUUU������    UUUU������    UUUU�����Z�    UUUUӺ�3�Z�    UUUU���3�Z�    UUUU���3�Z�    UUUU�v�:Z�    UUUUz^�3:b��    UUUUaH�:b��    UUUUJ4�3:b��    UUUU5$�#:`��    UUUU%�:���    UUUU�:���    UUUU�:�/�    UUUU��>�#�    UUUUvb's2;    UUUU $C2$C���aU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU 	�!���aPTTT��؉�x    UUUUy��y�S    UUUUqw7�R    UUUUy�wq�    UUUU%yS7�    UUUU7&yW1�    UUUUN8yS7�    UUUUhMyS��    UUUU�gyS��    UUUU��yS�`    UUUU��yS�d
    UUUUԺys�d    UUUU��yys�T
    UUUU��yys��	    UUUU��ys��	    UUUU��{�&�M    UUUU�����%IJ    UUUU���}�v�V    UUUU�����?)I    UUUU��1I�$I    UUUU��#I�$I    UUUU������$I    UUUU������/�    UUUU�����d+�    UUUU�����[-�    UUUU���3��    UUUU�����Z�    UUUU����Z�    UUUU���3�Z�    UUUUε�3:Z�    UUUU���#:Z�    UUUU���#�Z�    UUUU�j�#:b��    UUUUkQ�#:Z��    UUUUR<�#:b��    UUUU<*�#:���    UUUU)�#:b��    UUUU�:���    UUUU
�:�#�    UUUU	�>�#�    UUUU�C:�#�    UUUUL�$LB&    UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU �{�g{��aTTUU�{�o    UUUU	y��y�W    UUUU	1uS/�    UUUUyW1�    UUUU)yW1u    UUUU<*qS��    UUUUU>yS1�    UUUUqVyS��    UUUU�ryS��    UUUU��yS��    UUUUȭyS�`    UUUU��yS�d    UUUU��yS�`
    UUUU��yys�T    UUUU��q�R��	    UUUU�����/YR    UUUU��I�J�DI    UUUU���m۶m    UUUU�           UUUU�           UUUU�           UUUU�           UUUU��$C�$I�    UUUU��l"�R/�    UUUU���C�")�    UUUU�����c��    UUUU���3:Z�    UUUU��3�Z�    UUUU���3:Z�    UUUU���#�Z�    UUUUĪ�#:X��    UUUU���#:X��    UUUU�t�#:b��    UUUUsZ�#:X��    UUUUYB�#:���    UUUUA/�#:���    UUUU-�#:���    UUUU�>��    UUUU�#:X��    UUUU
�>�#6    UUUUs2'��9    UUUUdB&dB&    UUUU L�$L�$��a          ��UUUU          ��UUUU          ��UUUU I�$I����a   @I��	��    UUUU1S6eS    UUUU
qwwwuW    UUUUyS1u    UUUUyS1    UUUU-1S��    UUUUA/yS�    UUUU[DyS1�    UUUUy]9S/�    UUUU�{yS��    UUUU��9S��    UUUUзqS��    UUUU��yS��    UUUU��yS��    UUUU��yS�`
    UUUU��y��/uR    UUUU��ɟ���J    UUUU��ٶm۶m    UUUU�           UUUU�           UUUU�           UUUU�           UUUU�           UUUU�           UUUU��$C�$I�    UUUU��I"&�,�    UUUU�����l/�    UUUU���3�c��    UUUU���:b��    UUUU�ޣ#�X�    UUUU���#:X��    UUUU̴�#:X��    UUUU���#:X��    UUUU�|�#:X��    UUUUza�#:���    UUUU^H�#:���    UUUUE3�#:��9    UUUU0"�#:���    UUUU �#:�:    UUUU�#:�:    UUUU�>�#>    UUUU�#:�#:    UUUU�3;�3;    UUUU L�$LB&��a          ��UUUU          ��UUUU          ��UUUU I��I����a@@@@	��	��    UUUU��1S    UUUUywwuW    UUUU1S1�    UUUUyS1    UUUU0!1S1�    UUUUE29��    UUUU`H1��    UUUUd9S�    UUUU��1S��    UUUU��9S��    UUUUտ1S��    UUUU��qS��    UUUU��yS��    UUUU��1�r�dN    UUUU������uW    UUUU��ٶm۶m    UUUU�           UUUU�           UUUU�           UUUU�           UUUU�           UUUU�           UUUU�           UUUU�           UUUU�           UUUU����>�#�    UUUU���C�b/�    UUUU����    UUUU��#6Z��    UUUU�Ң#6X��    UUUUѻ�#:X��    UUUU���:��5    UUUU���:���    UUUU~f�:��5    UUUUaL�:��9    UUUUH6�:��9    UUUU2$�:��9    UUUU!�:��9    UUUU�#:�:    UUUU�:���    UUUUs2's2;    UUUU�3;�3;    UUUU dB&dB&��a          ��UUUU          ��UUUU          ��UUUU I��	����a@@PP�{�{    UUUU1S1S    UUUU��wyW    UUUU1��    UUUU!yS1    UUUU2#1��    UUUUI51S1�    UUUUdM9S1    UUUU�i1�    UUUU��1�    UUUU��1�    UUUU��1S��    UUUU��1S��    UUUU��qS)�    UUUU��qwO��N    UUUU����O�tO    UUUU�           UUUU�           UUUU�           UUUU�           UUUU�           UUUU�           UUUU�           UUUU�           UUUU�           UUUU�           UUUU��R"1�")    UUUU���C:�#:    UUUU��9���    UUUU��:X�5    UUUU�ע�9X�5    UUUU����9��5    UUUU���:��9    UUUU����9��9    UUUU�i�:��9    UUUUcN��9��9    UUUUI8�:�:    UUUU3%�:��9    UUUU"�:�:    UUUU��9��9    UUUU�>�#>    UUUU�#:�#:    UUUU�3;�3;    UUUU dB&dB&��a          ��UUUU          ��UUUU          ��UUUU 	��	����aPPPP�{�{    UUUU����S    UUUUquW�tO    UUUU1�    UUUU"11    UUUU4%1�    UUUUK891    UUUUgP11    UUUU�l1�    UUUU��1�    UUUUì1�    UUUU��1�    UUUU��1�    UUUU����    UUUU��)�R/�J    UUUU����S��W    UUUU�           UUUU�           UUUU�           UUUU�           UUUU�           UUUU�           UUUU�           UUUU�           UUUU�           UUUU�           UUUU���"1�"1    UUUU��s2;�3;    UUUU����:��:    UUUU��6`6    UUUU�٘�9��9    UUUU��9��9    UUUU����9��9    UUUU���:�:    UUUU�j�:�:    UUUUcO�:�:    UUUUI8�:�:    UUUU3&��9�:    UUUU"�:�:    UUUU��9��9    UUUU�#>�#>    UUUU�#:�#:    UUUU�3;�3;    UUUU dB&dB&��a          ��UUUU          ��UUUU          ��UUUU 	��	����aPPPP�{�{    UUUU1S1S    UUUUy�WyW    UUUU11    UUUU#11    UUUU5'11    UUUUL:1�    UUUUhR1�    UUUU�o��    UUUU����    UUUUĮ��    UUUU����    UUUU��11    UUUU����
��    UUUU���K�S    UUUU����K9�S    UUUU�           UUUU�           UUUU�           UUUU�           UUUU�           UUUU�           UUUU�           UUUU�           UUUU�           UUUU�           UUUU��#ɒ,)    UUUU��"-Ң#:    UUUU����:��>    UUUU��`:�#:    UUUU�ؘ�9�#:    UUUU��X�5�#:    UUUU����9�:    UUUU����9�:    UUUU�h��9�:    UUUUcN�:�#:    UUUUI7��9�#:    UUUU3%�:�#:    UUUU"�:�>    UUUU�:�:    UUUU�����:    UUUU�#;tB'    UUUU�3;�3;    UUUU dB&dB&��a          ��UUUU          ��UUUU          ��UUUU 	��	����aPPPP�o�o    UUUU1S1S    UUUUqWqW    UUUU��    UUUU$91    UUUU6'1�    UUUUM;11    UUUUhS��    UUUU�o��    UUUU����    UUUUĮ��    UUUU����    UUUU���)S    UUUU����    UUUU��/�R)�R    UUUU���[��    UUUU�           UUUU�           UUUU�           UUUU�           UUUU�           UUUU�           UUUU�           UUUU�           UUUU�           UUUU�           UUUU��#:b"&    UUUU���#:�C:    UUUU��Z��b?:    UUUU��X��Z#:    UUUU��X�9�#:    UUUUҽX�9�#:    UUUU��X�5�#:    UUUU��X�9�#:    UUUU~eX:�#:    UUUU`K��9�#:    UUUUG5��9�#:    UUUU2#X:�#:    UUUU!�#:�>    UUUUX�9�#:    UUUU��>�>    UUUU�-ڢ#:    UUUU�3;�3;    UUUU dB&L�$��a          ��UUUU          ��UUUU          ��UUUU 	��	����aPPPP�o�o    UUUU1S1S    UUUUqWqW    UUUU��    UUUU$1S9�S    UUUU5'�1    UUUUL:��    UUUUhQ11S    UUUU�m�1    UUUU���1    UUUUª��S    UUUU���1S    UUUU���N1S    UUUU���)S    UUUU���twq�w    UUUU���o�{    UUUU���dI&S    UUUU�           UUUU�           UUUU�           UUUU�           UUUU�           UUUU�           UUUU�           UUUU�           UUUU��۶m۶%    UUUU����>��?    UUUU��b/�b�>    UUUU����b#:    UUUU��X��b#:    UUUU��X�5�#:    UUUUηX�5�#:    UUUU��X�9�#:    UUUU�}X�9�#:    UUUUy`X�5�#:    UUUU]GX:�#:    UUUUD1X:��>    UUUU/!X/:�#:    UUUU�/:��>    UUUUX:�#:    UUUU�����>    UUUU�#:�C;    UUUU�c;vb'    UUUU L�$L�$��a          ��UUUU          ��UUUU          ��UUUU 	��	����aPPPP�{�{    UUUU1S1S    UUUUqWy�W    UUUU11S    UUUU#11�W    UUUU5&�1S    UUUUK8�1�S    UUUUeO�1S    UUUU�i�1S    UUUU���1�S    UUUU���1S    UUUU����1S    UUUU����)w    UUUU����N1�w    UUUU����N1w    UUUU��/��i��    UUUU��6e���    UUUU����m�o    UUUU�           UUUU�           UUUU�           UUUU�           UUUU�           UUUU�           UUUU�           UUUU��-9�c'    UUUU��)�"-:    UUUU����c�:    UUUU��X-���>    UUUU����b?:    UUUU�����#>    UUUUɯX���3:    UUUU��X���>    UUUU�uX���#:    UUUUtZX�9��>    UUUUXBX/:��>    UUUU@.�:��>    UUUU,X/:��:    UUUUX/:��>    UUUU�/:��>    UUUU
�����>    UUUU�-ڢ-:    UUUUdB&d�$    UUUU L�$I�$��a            ��UUUU          ��UUUU          ��UUUU 	��	����aPPPP�{�{    UUUU1����    UUUU�tOqW    UUUU�1S    UUUU"1Sy�w    UUUU2$�1S    UUUUH5�1�W    UUUUaJ�1S    UUUU~d�1S    UUUU����1�w    UUUU����1�w    UUUUϸ��1�w    UUUU����N1�w    UUUU���N/w    UUUU����Rq��    UUUU���dn/�    UUUU���dR6�    UUUU��?�����    UUUU���dJ���    UUUU��۶m۶�    UUUU�           UUUU�           UUUU��$I�$I2    UUUU��۶-�2'    UUUU���m;v�$    UUUU��۶͛=;    UUUU��Ҫի�:    UUUU������>    UUUU���գ�>    UUUU������:    UUUU��X����>    UUUU��X����>    UUUU��X����:    UUUU�mX����>    UUUUlSX�5��>    UUUUR<X/���>    UUUU;)X�9��:    UUUU(X/:��>    UUUU�/:��:    UUUU	X/���:    UUUU	��>��>    UUUU�3;�3'    UUUU �=۳m;��aUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU 	��I����aP@@@�{��    UUUU1S1�    UUUUy�w��{    UUUU1S1�w    UUUU 1Sy�w    UUUU/!�1W    UUUUD1�S1�w    UUUU\E�S1�w    UUUUw]�1�w    UUUU�w��1�w    UUUU����N1�w    UUUUǭ��N1�w    UUUU�Ħ�N7�w    UUUU�ץ�N7��    UUUU���Nw��    UUUU��`Nq��    UUUU���Tn.�    UUUU���DJ6�    UUUU����m���    UUUU���fo���    UUUU��6eۉ�$    UUUU���D���$    UUUU��i�v�$    UUUU���<۶�$    UUUU���(�$M;    UUUU��K�l�?    UUUU��Шѣ�>    UUUU��Ъ�c�>    UUUU��Ъ�b�>    UUUU������>    UUUUδ����>    UUUU������>    UUUU�X����>    UUUU�cX����>    UUUUdKX���>    UUUUK6X/���>    UUUU5%X:��>    UUUU$X/:�>    UUUU`/:��>    UUUU�����>    UUUU��>��?    UUUU�MڤM;    UUUU $C2dB&��a          ��UUUU          ��UUUU          ��UUUU          ��UUUU I��I�$��a@@@ 	��	��    UUUU&eS6S    UUUU
9�Sy��    UUUU�pS1�w    UUUU�pSq�w    UUUU,��R1w    UUUU>,�p1�w    UUUUU>�pS1�w    UUUUnT��N1�w    UUUU�l��N1�w    UUUU����N1�w    UUUU����N7��    UUUUз��N1��    UUUU�ʥ�N7��    UUUU�ڝ�Nw��    UUUU��`Nw��    UUUU��PNo��    UUUU��Tnn��    UUUU����n���    UUUU���T���    UUUU��$Ւ��    UUUU���D���$    UUUU���$�$m'    UUUU��I�m�'    UUUU��ڶֵ�'    UUUU�񐦱d_?    UUUU��Шѣ_?    UUUU��Ш�c�>    UUUU��Ъգ�>    UUUU־����>    UUUU¦�բ�>    UUUU������>    UUUU�sX����>    UUUUuYX-���>    UUUU[CX/���>    UUUUC/X/���>    UUUU0 X/:��>    UUUU X/���>    UUUUX/:�>    UUUUb?���:    UUUU�-:�C;    UUUU�3;vb'    UUUU dB&L�$��a          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU �g{�۞�aUUTT�{��x    UUUU	9��y��    UUUU	�pS1�w    UUUU�q�w    UUUU'��R1�w    UUUU8&�pO1�w    UUUUL7��Rq�w    UUUUcJ��N1�w    UUUU|`��N1��    UUUU�x��N1��    UUUU����Nw��    UUUU¦��N7��    UUUUӺ��Nw��    UUUU�˜`Nw��    UUUU�؜PNw��    UUUU��Pnv��    UUUU��Pnw��    UUUU��Prn��    UUUU���Mn��    UUUU��Drv��    UUUU���F���$    UUUU�򒴭��$    UUUU�𐴑��'    UUUU�쐶�m�'    UUUU��ж���?    UUUU��Ш�c_?    UUUU��Ъի_?    UUUU���ի_?    UUUUɮ�իO?    UUUU���գO?    UUUU�~�գ�>    UUUU�f����>    UUUUiOX����>    UUUUQ:X-���>    UUUU;)X����>    UUUU*X-���>    UUUUX/���>    UUUU
X/���>    UUUU
����S?    UUUU�-ڤC;    UUUUdB&L�$    UUUU L�$I�$��a             ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU !�	����aTTPP6e���    UUUU/�Ro��    UUUU.uSw��    UUUU/Wq��    UUUU"�pSq��    UUUU1 ��Rq��    UUUUC/��Rq��    UUUUX@��Rq��    UUUUnS��Nw��    UUUU�i��Nq��    UUUU�~��N7��    UUUU����N7��    UUUUç��Nw��    UUUUѸ�PNw��    UUUU�ƓPNw��    UUUU�ГPnw��    UUUU��@Nv��    UUUU�ޓ@nv��    UUUU��@rv��    UUUU���m��$    UUUU�� �m��$    UUUU�怴���$    UUUU�䐶���$    UUUU�߀����?    UUUU�؀����'    UUUU��Ш��_?    UUUU��Шլ_'    UUUUʰЪѫ_?    UUUU��Ъի_?    UUUU���իO?    UUUU�o-��O?    UUUUtX����>    UUUU\D����>    UUUUG2X-��C?    UUUU3"X-���>    UUUU$X/��C?    UUUUX/:��>    UUUUb?��C?    UUUUb�>��>    UUUU"-ڤM;    UUUU $C2$C&��a          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU 	��I�$��aP@@ ��؉��    UUUU/����    UUUU.usw��    UUUU
�pSy��    UUUU�pSy��    UUUU)��N7��    UUUU9'�pSq��    UUUUK5��R7��    UUUU_F��Nw��    UUUUuY��Rw��    UUUU�l��Nw��    UUUU���Nw��    UUUU���`Nw��    UUUU���PNw��    UUUUɯ�Pnw��    UUUUҺPNw��    UUUU��Pnv��    UUUU��@nw��    UUUU��@nv��    UUUU�� �mv�$    UUUU��@n��$    UUUU�Հ����$    UUUU�� ����$    UUUU�̀����'    UUUU�Ő����'    UUUUҺШ���'    UUUUǬШ���?    UUUU��Шլ_?    UUUU��Ъի_?    UUUU�tЪի_?    UUUU|_�ի_?    UUUUeK�իC?    UUUUP9-��C?    UUUU<)-���>    UUUU,X-��C?    UUUUX/���>    UUUUX/:�C'    UUUUZ���S?    UUUU�-:�C'    UUUU�3;vb'    UUUU dB&L�$��a          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU �g{�۞�aUUTT��x���    UUUU/�Ry��    UUUU/usy��    UUUU�psq��    UUUU!��Rq��    UUUU/��Rq��    UUUU?+��Rq��    UUUUP9��Rq��    UUUUcI��Nw��    UUUUuY��Nw��    UUUU�j��Nw��    UUUU�z��Nw��    UUUU���Pnw��    UUUU���Pnw��    UUUU��Pnw��    UUUUª@nw��    UUUUȱ@n���    UUUU̶@nv��    UUUUϻ@nv�$    UUUUо �m��$    UUUUо �m��$    UUUUϻ ����$    UUUU̶�����'    UUUUƮ�����'    UUUU�������'    UUUU��Ш���?    UUUU��ШѬ_?    UUUU�tЪլ_?    UUUU~aЪի_?    UUUUjO�ի_?    UUUUV>�իC?    UUUUC.�իO?    UUUU2!-���>    UUUU$-���>    UUUUX-��C?    UUUU�գ�>    UUUU	����_?    UUUU�M;�c'    UUUU �=۳m;��aUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU 	��I����aPP@@�{���    UUUU6����    UUUU.usw��    UUUU	��Rq��    UUUU�psq��    UUUU%��Rw��    UUUU2!��Rw��    UUUUA-��Rw��    UUUUQ:��rq��    UUUUaG��Nw��    UUUUpU��Nw��    UUUUc�PRw��    UUUU�o�Pnw��    UUUU�{�Pnw��    UUUU���Prw��    UUUU��@nv��    UUUU��@n���    UUUU��@n��$    UUUU��@n��$    UUUU�� �m��$    UUUU�� ����$    UUUU�� ����$    UUUU�������$    UUUU�������'    UUUU�������'    UUUU�}�����?    UUUU�oШ���?    UUUU{_ШѬ_?    UUUUjPЪլ_?    UUUUX@Ъի_?    UUUUG2�ի_?    UUUU7%���S?    UUUU)-��O?    UUUUX-��S?    UUUU
X-���>    UUUUb���S?    UUUU-ڤC'    UUUU�=;�c'    UUUU $C&d�$��a          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU �g{��؞�aUUTP&eS6�    UUUU�tw���    UUUU��Rw��    UUUU��vq��    UUUU��R��    UUUU'��rw��    UUUU3"��Rq��    UUUU@,��Rw��    UUUUM7��rw��    UUUUZB�`nw��    UUUUfM��rw��    UUUUrW�Pnw��    UUUU|a�Pnw��    UUUU�jPn���    UUUU�qPnw��    UUUU�x@n���    UUUU�~@nv��    UUUU��@n��$    UUUU��@r��$    UUUU�� �m��$    UUUU�� ����$    UUUU�� ����$    UUUU�z�����'    UUUU�q�����'    UUUU�f�8���'    UUUUtYи���?    UUUUfLиլo?    UUUUW?�*֬_'    UUUUH2+֬_?    UUUU9&+֬_?    UUUU,-��S'    UUUU -��_?    UUUU=ګS?    UUUU�գ�:    UUUUb/���?    UUUU�M;tb'    UUUU �=۳m;��aUUU L�$I�$��a             ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU 	��I�$��aPP@ !��I��    UUUU&eS���    UUUU	�tw���    UUUU��Nw��    UUUU��vy��    UUUU��Rw��    UUUU&��rw��    UUUU0 ��Rw��    UUUU;(��rw��    UUUUE1�Prw��    UUUUO:��n���    UUUUYB��r���    UUUUaIPnw��    UUUUiQPr���    UUUUpWPrw��    UUUUv]Prv��    UUUUzb@nv��    UUUU~g@r��$    UUUU�j @n��$    UUUU�l ����$    UUUU�j ����$    UUUU}f�����$    UUUUya�6���$    UUUUqY�����'    UUUUhP�����'    UUUU]EШ���'    UUUUQ;�8֬�'    UUUUE0�:֬�?    UUUU8&�:֬o'    UUUU,+֬_?    UUUU!+֬_?    UUUU=��c'    UUUU-��S?    UUUU
Z���c?    UUUUb����?    UUUU�3;vb'    UUUU $C&L�$��a          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU $�	����aUTP@�{���    UUUU-����    UUUU	-��y��    UUUU��ry��    UUUU��r���    UUUU��rw��    UUUU#��rw��    UUUU+�Pnw��    UUUU3"��rw��    UUUU;)��r���    UUUUB/�Prw��    UUUUI5�Prw��    UUUUP;�Pr���    UUUUU@Pn���    UUUU[E@r���    UUUU_J@n���    UUUUcN@n��$    UUUUeQ@���$    UUUUeR �m��$    UUUUeQ 0���$    UUUUcN�����$    UUUU_J�����$    UUUUYC�6���'    UUUUQ<�����'    UUUUH4�8���'    UUUU>+�8���'    UUUU4#�8֬�'    UUUU*�(֬_?    UUUU!;֬�?    UUUU=ڬc'    UUUU	=���'    UUUU;֬_?    UUUUb����'    UUUU"Mڴm;    UUUU �m۶c'��aUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU I�$I�$��a@    �g۱�؞�aUUTP�f{���    UUUU&����    UUUU	��vw��    UUUU��rw��    UUUU
��Rw��    UUUU��r���    UUUU��rw��    UUUU$��r���    UUUU*��r���    UUUU/ Pnv��    UUUU5$�Prw��    UUUU:)�Pr���    UUUU?-Pr���    UUUUC1@n���    UUUUG5@n��$    UUUUJ8@n��$    UUUUL; @���$    UUUUM< @���$    UUUUL< ����$    UUUUK9 ����$    UUUUH6�6���$    UUUUC1�����$    UUUU=+ж���'    UUUU6%�8���'    UUUU.�8���'    UUUU&�8֬�?    UUUU)֬�?    UUUU�:ִo'    UUUU	=���'    UUUUZ����'    UUUUbK���?    UUUU-ҤM;    UUUUd�$I�$    UUUU d�$I�$��a            ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU I��I�$��a@@   �g۶۞�aUUUT�f{���    UUUU-����    UUUU�����    UUUU�䒷��    UUUU	��r���    UUUU�Вw��    UUUU��r���    UUUU��r���    UUUU ��r���    UUUU$�P����    UUUU(��r���    UUUU,�Pr���    UUUU/!�Pr���    UUUU3$@r���    UUUU5&@nv��    UUUU7( @nv��    UUUU7* �m��$    UUUU7* ����$    UUUU6(�4���$    UUUU4%�����'    UUUU0"�6���$    UUUU+�6���'    UUUU&�6ֵ�'    UUUU �8���'    UUUU�8ֵ�'    UUUU�:���'    UUUUШ��_?    UUUU;֭o?    UUUU"K���?    UUUU�=;v�$    UUUU$C&L�$    UUUU $C&L�$��a           ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU 	��I�$��aP@   �g۶�؞�aUUUP�f{���    UUUU&e����    UUUU%Ֆ��    UUUU	�Ԓ��    UUUU�Ԓw��    UUUU�Prv��    UUUU
�В���    UUUUPr���    UUUU�rw��    UUUU�Ж��$    UUUU�Pr��$    UUUU �В��$    UUUU"�Pr���    UUUU$Pr��$    UUUU&�@���$    UUUU& @���$    UUUU& @���$    UUUU% 4���$    UUUU$�D���$    UUUU!�6���$    UUUUж���$    UUUU�8���$    UUUU�8���$    UUUU
�8֭�'    UUUU;ֵ�?    UUUU
Z����'    UUUU)ڴc'    UUUUIҤm;    UUUU$C&L�$    UUUU $C&L�$��a           ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU I�$I�$��a@    $I�	����aUUP@$��I�$    UUUU$e���    UUUU�d����    UUUU%Ֆ��    UUUU�T�o��    UUUU
�Ԗ���    UUUU�䶿��    UUUU�Ԓ���    UUUU	�@rv��    UUUU�Pr���    UUUU�Pr��$    UUUU�В��$    UUUU@r��$    UUUU @n��$    UUUU@���$    UUUU D���$    UUUU 4���$    UUUU�D���$    UUUU�6���$    UUUU�6���$    UUUU	�����?    UUUU�8���?    UUUU
Һֵ�?    UUUU"����$    UUUU)Ҥm;    UUUU"Mڶm'    UUUU �=۶m;��aUUU $C&L�$��a           ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU $��I�$��aUP   �g۶۞�aUUUT�g�I�$    UUUU�fo��    UUUU�fo��$    UUUU$e���$    UUUU$Ֆ��    UUUU�Ԗ���    UUUU	�Ԗ���    UUUU
�Ԓ���    UUUU�䶿��    UUUU�Զ���    UUUU	�Զ��$    UUUU	�T����    UUUU
�Զ��$    UUUU
�Զ��$    UUUU	�F���?    UUUU	�ֶ��$    UUUU�����$    UUUUҶ���?    UUUU	I���'    UUUU"����$    UUUU"I�v�$    UUUU�=�v�$    UUUU�m�v�$    UUUU �m۶m'��aUUU d�$I�$��a            ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU I�$I�$��a@    $�I�$��aUT@  $I�$����aUUUP$��I�$    UUUU�f۱�$    UUUU�fo��    UUUU�fۉ�$    UUUU�d���    UUUU$e���$    UUUU�D�6�    UUUU�D���$    UUUU�d���$    UUUU�D���$    UUUU	�Ԗ��$    UUUU	�D���$    UUUU	"ٶ��$    UUUU�HҶ�$    UUUU�D���$    UUUU�H��m'    UUUU�H��m;    UUUU�m�v�$    UUUU�m۶�$    UUUU$�$I�$    UUUU $I2d�$��aU  L�$I�$��a             ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU !�$I�$��aT    $I�	�$��aUUP  $I�$���aUUUT$�$I�$    UUUU$I�I�$    UUUU�f۶�$    UUUU$��I�$    UUUU�f�I�$    UUUU�f{��$    UUUU$E���    UUUU�f�I�$    UUUU�f�I�$    UUUU�m�I�$    UUUU�6۶�$    UUUU�m�v�$    UUUU۶ٶm;    UUUU�m�v�$    UUUU$�$I�$    UUUU $I�$�$��aUU $�$I�$��a            ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU !�$I�$��aT    $�I�$��aUT   $I�!�$��aUUT            UUUU$�$I�$    UUUU$�I�$    UUUU$I�I�$    UUUU$I�	�$    UUUU$I�$�$    UUUU$I�I�$    UUUU$I�I�$    UUUU$�$I�$    UUUU           UUUU $I�d�$��aUU  $�$I�$��a            ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU $�$I�$��aU    $�I�$��aUT   $I�I�$��aUU@  $I�$�$��aUUU  $I�$�$��aUUU  $I�$�$��aUU  $I�I�$��aUU   $�$I�$��aU            ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU I�$I����0�   P I�$IB���0�   U I�$IB���0�   U I�$I�$��0�             ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU I�$	I���a  hW I۶�m��a zUUI�$��m�{APUUUI�6II    UUUUIb�$)I    UUUUIb�$)I    UUUUIb'�-�    UUUU vb�$-���a*UUU Ib'��͞�a UU I�$LB2��a  �          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU I�$I����a  `X �m�6IJ��axWUU���v�I    UUUU	�o�%7	    UUUUI~�%'    UUUUI��-)    UUUUI��m	     UUUUI��m@    UUUUI��dH    UUUUIb�di    UUUU	R�dm    UUUU�����    UUUU vb;�-���a	�UU I�$LB2��a  5          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU I�ĉ{��a `XVI���R�9  TUUUI��wY    UUUUI��.�	    UUUU	I��-7    UUUUIr�%7    UUUU$I��%)    UUUU&Ir�$	     UUUU%Ib�$	     UUUU$Ib�$H    UUUUOb�ch    UUUU	Ib�dm    UUUUb�k�    UUUU~R�l�    UUUUO�?���    UUUU I�$�3۞�a	5�          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU I�ĉ�x��a �pXɟ߿wW�9  TUUU���w�    UUUU	ɝ�.W
    UUUU)�}�.�	    UUUU7��-�	    UUUUD"I~�%7    UUUUM)Ir�%'    UUUUQ-Ib�$	     UUUUQ-Ib�$	     UUUUM(Ib�#	@    UUUUD!OR�#h    UUUU8R�#i    UUUU*R�c�    UUUU	~R�c�    UUUU~R?c�    UUUU�S����    UUUU Nb'��ٞ�a5�          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU I�$I����IJ  �@ ���o�R��aTVUU���7�    UUUU	ɛ�/g    UUUU1�}�.U
    UUUUJ#�}�.�	    UUUUc4�}�.�	    UUUUyE��%7    UUUU�SI~�$'    UUUU�\Ib��     UUUU�\Ib��     UUUU�SOR�	H    UUUUzF��h    UUUUf6��h    UUUUO&~��c�    UUUU8~��c�    UUUU"~�>c��    UUUU�C����    UUUU�S?�/�    UUUU I�$v2;��a	%          ��UUUU          ��UUUU          ��UUUU          ��UUUU I�؉{��a`pPX	���7�    UUUU��w7�    UUUU.��w/e    UUUUO&��/U
    UUUUt?�{���	    UUUU�[�}���	    UUUU�v�}��4    UUUU���o��&    UUUUșIb��     UUUUȚIR��     UUUUÍ��	H    UUUU�y~��h    UUUU�a~���    UUUU~F~��Z�    UUUU\.���b�    UUUU<��:b��    UUUU!��:b��    UUUU��>��    UUUU �S������a�UU I�$I�$��IJ            ��UUUU          ��UUUU          ��UUUU y���R��aTVVU��{qu    UUUU"�w7�    UUUUD�w7�    UUUUp<�w/e
    UUUU�a�{w�T
    UUUUŉ�{���	    UUUUݫ�}��4    UUUU�����$    UUUU��I��&     UUUU��I���@    UUUU�����H    UUUU����h    UUUU˒����    UUUU�o���Z�    UUUU�K���b�    UUUUY,��:b�    UUUU3��:b��    UUUUt�>���    UUUU	��>��    UUUU Nb's2'��a	%          ��UUUU          ��UUUU I��I����a���@��{wuW    UUUUy�W9    UUUU.�w1�    UUUUY-yS/�    UUUU�Tys�d
    UUUUÅyys�T
    UUUU䴹ys��	    UUUU�չ�r�4    UUUU���r�$    UUUU���߶�&     UUUU��O���     UUUU��~B��h    UUUU���3��
h    UUUU��3��    UUUUИ�3��    UUUU�k�3�Z�    UUUUuA�3:Z�    UUUUF!��:���    UUUU"�:���    UUUUt�>�:    UUUU ��>����a5��          ��UUUU          ��UUUU I�؉�x��a```Pyw7uS    UUUU	y�W1    UUUU9yS7�    UUUUm;yS1�    UUUU�lyS��    UUUUڥywS�`
    UUUU��q�N��	    UUUU��q�n��	    UUUU����v�      UUUU���EI�$I    UUUU��b"I�$I    UUUU������*�    UUUU���3��    UUUU���#��    UUUU��#��    UUUU���#:X�    UUUU�U�#:X��    UUUUU-�#:���    UUUU+�#>��9    UUUU�>�:    UUUU��>�#>    UUUU I�$L�$��0�            ��UUUU ��x�{��aPXXX
qS1q    UUUUy�W1    UUUUB!yS1    UUUUzH9S��    UUUU��1S��    UUUU�1O�p
    UUUU��1�N�`
    UUUU��q�R&�    UUUU�           UUUU�           UUUU�           UUUU�           UUUU������,�    UUUU��Z�    UUUU�Т�5X�    UUUUΞ�#:X��    UUUU�e�:���    UUUU^6�:��9    UUUU0�:�:    UUUU�>�>    UUUUj�>�>    UUUU L�$L�$��a          ��UUUU 1S1S��aXTTTy�Wy�    UUUU 91    UUUUH&91    UUUU�Q1�    UUUU��1�    UUUU����    UUUU��)���
    UUUU���tI�tJ    UUUU�           UUUU�           UUUU�           UUUU�           UUUU��۲�۲-    UUUU����5X5    UUUU�ښ�9X�5    UUUUѨ��9X�5    UUUU�m��9��9    UUUU`;�:��9    UUUU1�>�>    UUUU	�>�>    UUUU�>�>    UUUU L�$L�$��a          ��UUUU 1S1S��aTTTT11    UUUU"11    UUUUI)1�    UUUU�V��    UUUU����    UUUU����    UUUU����    UUUU���I�K    UUUU�           UUUU�           UUUU�           UUUU�           UUUU���(��,)    UUUU��P�5X�9    UUUU��X�5X�9    UUUUѥX�5�:    UUUU�iX�9�:    UUUU_8�:�#>    UUUU1�:�#>    UUUU�>�>    UUUU�>�>    UUUU L�$L�$��a          ��UUUU 1S1S��aTTTT11    UUUU"11�S    UUUUI(�1    UUUU�S�1S    UUUU����S    UUUU�į��S    UUUU��p
�S    UUUU����Rw�    UUUU��$I�$�    UUUU�           UUUU�           UUUU�           UUUU��Ҭժ?;    UUUU����Z?:    UUUU���X#:    UUUU˘X���#:    UUUU�^X�9�#:    UUUUY1X�9��>    UUUU-�:��>    UUUU�/:�>    UUUU�>�3?    UUUU L�$L�$��0�           ��UUUU 1S1���aTT\X9�Wy�t    UUUU �9�w    UUUUE#�1�W    UUUUzI�1�w    UUUU�|��1�w    UUUU߲��1�w    UUUU�ڝ`�w    UUUU��PJ.��    UUUU����rv��    UUUU���$I���    UUUU���$Ii;    UUUU��Ҫյo?    UUUU���b�:    UUUU��Ъ�b�:    UUUU���b�>    UUUU������>    UUUU�OX����>    UUUUN(X:��>    UUUU&�/:�>    UUUU��:�3'    UUUU b����>��aUՕ          ��UUUU          ��UUUU ��x��؞�aXXP`
1Sy�{    UUUU
/Sq�w    UUUU;�p1�w    UUUUi:��R1�w    UUUU�e��N1��    UUUU̕��N7��    UUUU远`N/��    UUUU���M.��    UUUU���M.��    UUUU���mm��    UUUU�󀴍m�$    UUUU��l�?    UUUU�ဦ�c]?    UUUU��Ш�c�>    UUUUҜ�գ�>    UUUU�k����>    UUUUp>X����>    UUUU@X/���>    UUUUX/:�>    UUUU��>�C'    UUUU �C;tB'��a%%          ��UUUU          ��UUUU 	��I�$��a`@��7uwy��    UUUU�pSq��    UUUU.�pSy��    UUUUS*��Rq��    UUUU�J��Rq��    UUUU�q��Nw��    UUUU͖�PNw��    UUUU�PNo��    UUUU���Mn��    UUUU���mn��    UUUU�� �m��$    UUUU�� ��l�'    UUUU澀��dm?    UUUUՠШѫ_?    UUUU�yЪի_?    UUUU�O���C?    UUUUX,-���>    UUUU0X/���>    UUUUX/��C?    UUUUb/��O?    UUUU d�$L�$��a		          ��UUUU          ��UUUU          ��UUUU o��y����aUVTX�ps���    UUUU��Ry��    UUUU;��Rq��    UUUU^0��Rw��    UUUU�K��Nw��    UUUU�g�PNw��    UUUU�PNw��    UUUUŒ@nv��    UUUU̟�mv��    UUUUͧ �m��$    UUUU̠ ����$    UUUU�����'    UUUU�tШ���'    UUUU�TЪլ_?    UUUUf5+֬_?    UUUU@-��S?    UUUU"X-��S?    UUUUX���S?    UUUU b����?��aUՕ5          ��UUUU          ��UUUU          ��UUUU          ��UUUU ���I�$��aP`@�/uw���    UUUU�pw���    UUUU$��ry��    UUUU=��rw��    UUUUV+��rw��    UUUUm=Pnw��    UUUU�MPnw��    UUUU�[@nw��    UUUU�f@nv�$    UUUU�n �m��$    UUUU�j ����$    UUUU�]�����'    UUUU|Iи���'    UUUUa3�(֬�?    UUUUD+֬_?    UUUU)-��S'    UUUUX=��S'    UUUUX=��_?    UUUU sb'N�$��a%	          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU 6���Ğ�aW\X`��Rw��    UUUU��r���    UUUU!��r���    UUUU0��rw��    UUUU?�r���    UUUUL'Pr���    UUUUW0Pr���    UUUU_8@n��$    UUUUb> @r��$    UUUUb< ����$    UUUU\4�6���$    UUUUN'�8���'    UUUU;�8֭�'    UUUU'+���'    UUUU+���'    UUUU
X�:��'    UUUU �M:�c'��aU�5          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU I�$I�$��0�@    6e���؞�aUW\`��r���    UUUU�p����    UUUU��r���    UUUU��r���    UUUU&�В���    UUUU-Pr���    UUUU3Pr��$    UUUU5 @���$    UUUU5 @���$    UUUU1�����$    UUUU)�8���$    UUUU�8���'    UUUU;ֵ�?    UUUU
X����$    UUUU b����'��aUU�% L�$I�$��a	            ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU        ���@    �ۉ�$��aU\` -��ɟ$�9  UUUT�䖿��    UUUU�В���    UUUU�����$    UUUU�В��$    UUUU	�В��$    UUUU
�P���$    UUUU
�D���$    UUUU	�ƶ��$    UUUU�H���$    UUUU����'    UUUU����?    UUUU "Mڶc'��aU�5	 L�$I�$��a	            ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU 	�$I�$��ax�   �f�I�$��aUV�  �d��۞�aUUUx$����$    UUUU�����$    UUUU�Ԗ���    UUUU�Զ��$    UUUU	�ֶ��$    UUUU�ƶ��?    UUUU�����?    UUUU "����?��AUUU5 �m;N�$��a�%         ���             ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU !�$I�$��az    $�I�$��aUZ   �f۶�$��aUUz  �f{��؞�aUUU� ۶ٶm;��AUUU* �f۶�$��aUU�  $I2I�$��aU%   L�$I�$��IJ	             ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU I�$I����e)   p I�$�MJ��a  xU I��oKI��a  UU I�'m/���a  UU I�$�#Ҟ�a  /U I�$I�$��Mk   	          ��UUUU          ��UUUU          ��UUUU          ��UUUU          ��UUUU I��ɛW��a @XVI��wY�{ATUUUI��n�	    UUUU"I��-)     UUUU"I��d@    UUUUI�?l�    UUUU b�����AUUU I�$~����a %�          ��UUUU          ��UUUU          ��UUUU I�ĉ�P��a @pXɟ�y�a  TUUUCɟ�7W
    UUUUoI��.�	    UUUU�.Ir�$'     UUUU�.Ib�#	@    UUUUqOR�c�    UUUUGR?c�    UUUUO�?���    UUUU O�'u�>��a%          ��UUUU          ��UUUU ɛ�y���a\TWU<	���7�    UUUU�+��/e
    UUUU�d�}��D    UUUU��$     UUUU����     UUUU�j~��h    UUUU�4~��b�    UUUUQ}�>���    UUUU}B?���Z  UUU I�$N�$��a  I��I����e) �@@��{y�    UUUUcy�W1q    UUUU�^yS�`
    UUUU��qgN�0    UUUU��[n�      UUUU������     UUUU�ȫ���h    UUUU�u�#��    UUUU�&�:���    UUUU&t�>�:    UUUU }�'j�>��a	 I����X��a@@``y�Wy�    UUUUz&y1    UUUU�1���
    UUUU���t
��	    UUUU�           UUUU�           UUUU��Z���    UUUU�5P�    UUUU�<�:��9    UUUU-	�>�>    UUUU �>�>��a%%%% ��X��X��a````y�y�    UUUU{-11    UUUU攩�
�    UUUU���	��N    UUUU�           UUUU�           UUUU���
��5    UUUU��X�9    UUUU�7��9�#>    UUUU,�>�>    UUUU �>�3'��a%% ���I�Ğ�a``@@1�Wy�{    UUUUq �q�w    UUUU�n��1�w    UUUU���	�w    UUUU��0I��    UUUU�� $m#k?    UUUU�΀�=:    UUUU�t����>    UUUU{"X:��>    UUUU"��>�C?    UUUU r"'t�$��a	 I�$I�$��Mk@�  q�w�����AUUUTK�pSy��    UUUU�6��Rw��    UUUU�qPNw��    UUUU��In��    UUUU�  mm�$    UUUU�}���do?    UUUU�<���S?    UUUUPX/��S'    UUUU��>t�'�{AUUU L�$I�$���Z            ��UUUU y��ɝ��aTXp@�pw���    UUUUN��r���    UUUUw"�r���    UUUU�6Pr��$    UUUU�B ����$    UUUU�-�6���'    UUUUY;���'    UUUU$X�:��'    UUUU �C?~�$��a%          ��UUUU          ��UUUU        ���@    7��ɝ��aUTp��p���$a  UUUT!�����$    UUUU.В��$    UUUU1 @���$    UUUU-�����$    UUUU����$    UUUU �C'O�$��aU�%        ��4�             ��UUUU          ��UUUU          ��UUUU          ��UUUU ��$I�$��aX    %��I�$��aUW�  ��������aUUW��Զ��$Mk  UUU� �����'��aUU�
 �m'I�$��a�-         ����             ��UUUU          ��UUUU          ��UUUU I�$ɝ��a �PV I�$�M��a WUU I�$����a �UU I�$�>��a  �          ��UUUU I��I���a�@`PI��yw    TUUU�'I~��6    UUUU�'OR�h    UUUU�O�'���    UUUU I�$|'��a	% ɛ|ɕ��aPX\\� yS�    UUUU���T      UUUU��Z� @    UUUU�2�9X�    UUUU% |"'p?��a ����|��a\\\\�*�1�W    UUUU��0 �N    UUUU�� `��1    UUUU�-P�5��>    UUUU$ h"'{�'��a5 ���I�$��aPP`���w���    UUUU�-PNw��    UUUU�: ����$    UUUU�X�:��'    UUUU p�'N�$��a%	        ����@    1��I�$��aW\� % ��I�$��aUUU�)���I�$q�AUUU7 ��'I�$��aU5	         ��]�   Y I�$I���a `XT�I�$n-@�A(UUUf I�$N�&��a 	%� ��I�Xy�aTTVT��>@��    UUUU�j�&h"'��A��h ���I�$��aTXp ��ɓ$�s  UUU�o p�$I�$��a5� I��)��a�VWW� I�$H�$��a�U�� 1�$I�$��aVXXX5 H�$I�$}�a��yr�q'q�AWb         �9UUUU�?rt<��y��[remap]

importer="texture"
type="CompressedTexture2D"
uid="uid://d2oik12wohmhe"
path.s3tc="res://.godot/imported/d_shadow_1.png-ae09af55cb25d1a100c94410086974d2.s3tc.ctex"
metadata={
"imported_formats": ["s3tc_bptc"],
"vram_texture": true
}
 ��E{���qq�GST2   �   �      ����               � �        &  RIFF  WEBPVP8L  /������!"2�H�l�m�l�H�Q/H^��޷������d��g�(9�$E�Z��ߓ���'3���ض�U�j��$�՜ʝI۶c��3� [���5v�ɶ�=�Ԯ�m���mG�����j�m�m�_�XV����r*snZ'eS�����]n�w�Z:G9�>B�m�It��R#�^�6��($Ɓm+q�h��6�4mb�h3O���$E�s����A*DV�:#�)��)�X/�x�>@\�0|�q��m֋�d�0ψ�t�!&����P2Z�z��QF+9ʿ�d0��VɬF�F� ���A�����j4BUHp�AI�r��ِ���27ݵ<�=g��9�1�e"e�{�(�(m�`Ec\]�%��nkFC��d���7<�
V�Lĩ>���Qo�<`�M�$x���jD�BfY3�37�W��%�ݠ�5�Au����WpeU+.v�mj��%' ��ħp�6S�� q��M�׌F�n��w�$$�VI��o�l��m)��Du!SZ��V@9ד]��b=�P3�D��bSU�9�B���zQmY�M~�M<��Er�8��F)�?@`�:7�=��1I]�������3�٭!'��Jn�GS���0&��;�bE�
�
5[I��=i�/��%�̘@�YYL���J�kKvX���S���	�ڊW_�溶�R���S��I��`��?֩�Z�T^]1��VsU#f���i��1�Ivh!9+�VZ�Mr�טP�~|"/���IK
g`��MK�����|CҴ�ZQs���fvƄ0e�NN�F-���FNG)��W�2�JN	��������ܕ����2
�~�y#cB���1�YϮ�h�9����m������v��`g����]1�)�F�^^]Rץ�f��Tk� s�SP�7L�_Y�x�ŤiC�X]��r�>e:	{Sm�ĒT��ubN����k�Yb�;��Eߝ�m�Us�q��1�(\�����Ӈ�b(�7�"�Yme�WY!-)�L���L�6ie��@�Z3D\?��\W�c"e���4��AǘH���L�`L�M��G$𩫅�W���FY�gL$NI�'������I]�r��ܜ��`W<ߛe6ߛ�I>v���W�!a��������M3���IV��]�yhBҴFlr�!8Մ�^Ҷ�㒸5����I#�I�ڦ���P2R���(�r�a߰z����G~����w�=C�2������C��{�hWl%��и���O������;0*��`��U��R��vw�� (7�T#�Ƨ�o7�
�xk͍\dq3a��	x p�ȥ�3>Wc�� �	��7�kI��9F}�ID
�B���
��v<�vjQ�:a�J�5L&�F�{l��Rh����I��F�鳁P�Nc�w:17��f}u}�Κu@��`� @�������8@`�
�1 ��j#`[�)�8`���vh�p� P���׷�>����"@<�����sv� ����"�Q@,�A��P8��dp{�B��r��X��3��n$�^ ��������^B9��n����0T�m�2�ka9!�2!���]
?p ZA$\S��~B�O ��;��-|��
{�V��:���o��D��D0\R��k����8��!�I�-���-<��/<JhN��W�1���(�#2:E(*�H���{��>��&!��$| �~�+\#��8�> �H??�	E#��VY���t7���> 6�"�&ZJ��p�C_j����	P:�~�G0 �J��$�M���@�Q��Yz��i��~q�1?�c��Bߝϟ�n�*������8j������p���ox���"w���r�yvz U\F8��<E��xz�i���qi����ȴ�ݷ-r`\�6����Y��q^�Lx�9���#���m����-F�F.-�a�;6��lE�Q��)�P�x�:-�_E�4~v��Z�����䷳�:�n��,㛵��m�=wz�Ξ;2-��[k~v��Ӹ_G�%*�i� ����{�%;����m��g�ez.3���{�����Kv���s �fZ!:� 4W��޵D��U��
(t}�]5�ݫ߉�~|z��أ�#%���ѝ܏x�D4�4^_�1�g���<��!����t�oV�lm�s(EK͕��K�����n���Ӌ���&�̝M�&rs�0��q��Z��GUo�]'G�X�E����;����=Ɲ�f��_0�ߝfw�!E����A[;���ڕ�^�W"���s5֚?�=�+9@��j������b���VZ^�ltp��f+����Z�6��j�`�L��Za�I��N�0W���Z����:g��WWjs�#�Y��"�k5m�_���sh\���F%p䬵�6������\h2lNs�V��#�t�� }�K���Kvzs�>9>�l�+�>��^�n����~Ěg���e~%�w6ɓ������y��h�DC���b�KG-�d��__'0�{�7����&��yFD�2j~�����ټ�_��0�#��y�9��P�?���������f�fj6͙��r�V�K�{[ͮ�;4)O/��az{�<><__����G����[�0���v��G?e��������:���١I���z�M�Wۋ�x���������u�/��]1=��s��E&�q�l�-P3�{�vI�}��f��}�~��r�r�k�8�{���υ����O�֌ӹ�/�>�}�t	��|���Úq&���ݟW����ᓟwk�9���c̊l��Ui�̸z��f��i���_�j�S-|��w�J�<LծT��-9�����I�®�6 *3��y�[�.Ԗ�K��J���<�ݿ��-t�J���E�63���1R��}Ғbꨝט�l?�#���ӴQ��.�S���U
v�&�3�&O���0�9-�O�kK��V_gn��k��U_k˂�4�9�v�I�:;�w&��Q�ҍ�
��fG��B��-����ÇpNk�sZM�s���*��g8��-���V`b����H���
3cU'0hR
�w�XŁ�K݊�MV]�} o�w�tJJ���$꜁x$��l$>�F�EF�޺�G�j�#�G�t�bjj�F�б��q:�`O�4�y�8`Av<�x`��&I[��'A�˚�5��KAn��jx ��=Kn@��t����)�9��=�ݷ�tI��d\�M�j�B�${��G����VX�V6��f�#��V�wk ��W�8�	����lCDZ���ϖ@���X��x�W�Utq�ii�D($�X��Z'8Ay@�s�<�x͡�PU"rB�Q�_�Q6  h�[remap]

importer="texture"
type="CompressedTexture2D"
uid="uid://dojoe5c3708f8"
path="res://.godot/imported/icon.svg-218a8f2b3041327d8a5756f3a245f83b.ctex"
metadata={
"vram_texture": false
}
 Ѡ���]�{O�C~�shader_type canvas_item;

uniform vec4 background_color : source_color;
uniform vec4 shadow_color : source_color;
// Currently pixels always in application size, so zooming in further wouldn't increase the size of the dropdown
// but changing that would also be relatively trivial
uniform vec2 offset_in_pixels;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;

void fragment() {
	
	// Read screen texture
	vec4 current_color = textureLod(SCREEN_TEXTURE, SCREEN_UV, 0.0);
	
	// Check if the current color is our background color
	if (length(current_color - background_color) < 0.01) {
		
		vec4 offset_color = textureLod(SCREEN_TEXTURE, SCREEN_UV - offset_in_pixels * SCREEN_PIXEL_SIZE, 0.0);
		
		// Check if at our offset position we have a color which is not the background (meaning here we need a shadow actually)
		if (length(offset_color - background_color) > 0.01) {
			// If so set it to our shadow color
			current_color = shadow_color;
		}
	}
	
	COLOR = current_color;
}E!�&�L8��1�pRSRC                     PackedScene            ��������                                            v      resource_local_to_scene    resource_name    sky_top_color    sky_horizon_color 
   sky_curve    sky_energy_multiplier 
   sky_cover    sky_cover_modulate    ground_bottom_color    ground_horizon_color    ground_curve    ground_energy_multiplier    sun_angle_max 
   sun_curve    use_debanding    script    sky_material    process_mode    radiance_size    background_mode    background_color    background_energy_multiplier    background_intensity    background_canvas_max_layer    background_camera_feed_id    sky    sky_custom_fov    sky_rotation    ambient_light_source    ambient_light_color    ambient_light_sky_contribution    ambient_light_energy    reflected_light_source    tonemap_mode    tonemap_exposure    tonemap_white    ssr_enabled    ssr_max_steps    ssr_fade_in    ssr_fade_out    ssr_depth_tolerance    ssao_enabled    ssao_radius    ssao_intensity    ssao_power    ssao_detail    ssao_horizon    ssao_sharpness    ssao_light_affect    ssao_ao_channel_affect    ssil_enabled    ssil_radius    ssil_intensity    ssil_sharpness    ssil_normal_rejection    sdfgi_enabled    sdfgi_use_occlusion    sdfgi_read_sky_light    sdfgi_bounce_feedback    sdfgi_cascades    sdfgi_min_cell_size    sdfgi_cascade0_distance    sdfgi_max_distance    sdfgi_y_scale    sdfgi_energy    sdfgi_normal_bias    sdfgi_probe_bias    glow_enabled    glow_levels/1    glow_levels/2    glow_levels/3    glow_levels/4    glow_levels/5    glow_levels/6    glow_levels/7    glow_normalized    glow_intensity    glow_strength 	   glow_mix    glow_bloom    glow_blend_mode    glow_hdr_threshold    glow_hdr_scale    glow_hdr_luminance_cap    glow_map_strength 	   glow_map    fog_enabled    fog_light_color    fog_light_energy    fog_sun_scatter    fog_density    fog_aerial_perspective    fog_sky_affect    fog_height    fog_height_density    volumetric_fog_enabled    volumetric_fog_density    volumetric_fog_albedo    volumetric_fog_emission    volumetric_fog_emission_energy    volumetric_fog_gi_inject    volumetric_fog_anisotropy    volumetric_fog_length    volumetric_fog_detail_spread    volumetric_fog_ambient_inject    volumetric_fog_sky_affect -   volumetric_fog_temporal_reprojection_enabled ,   volumetric_fog_temporal_reprojection_amount    adjustment_enabled    adjustment_brightness    adjustment_contrast    adjustment_saturation    adjustment_color_correction    shader "   shader_parameter/background_color    shader_parameter/shadow_color "   shader_parameter/offset_in_pixels 	   _bundled       PackedScene    res://Player/player.tscn ��%'�19R   PackedScene    res://Objects/Block.tscn ��X��)4   Shader    res://main.gdshader ��������   $   local://ProceduralSkyMaterial_angma �         local://Sky_3ocpn O         local://Environment_e410u s         local://ShaderMaterial_jftq0 �         local://PackedScene_iksj8 *         ProceduralSkyMaterial          �p%?;�'?F�+?  �?	      �p%?;�'?F�+?  �?         Sky                          Environment                         !         C                  ShaderMaterial    q            r      ��?��?��?  �?s                    �?t               PackedScene    u      	         names "         Main    Node3D    WorldEnvironment    environment    DirectionalLight3D 
   transform    shadow_enabled    Player    Block    Block2    Block3    Block4    Block5    Block6    Block7    metadata/is_wallrunable    Block8    Block9    Block10 
   ColorRect    visible 	   material    offset_right    offset_bottom    color    	   variants                   ��]�F�ݾ" �>    ���>�]?2  ���??}�ݾ                                 �?              �?              �?�jD@��?���@              �A              �?              �A               �ZB            ff�A            ���?��T�H��?8iA   �+�A    ��Y�    P��A    �Z�A    \r�?��T�H��?��f�   ��ǵ    ��ٿ    ︣A    �ZB    ����C�lAH��?� e�   ��ǵ    ��ٿ    )\o@    �ZB    ������$�ףW�� e�     �?              �?              �?      �?  �@   �p�@              �?            �̜@  ��  @@  �@          ���A���      pA�g?              �A  ��   �       �ZB            P��A            ���?�R�H��?�[�   ��ǵ    ��ٿ    �k�A    �ZB    ���_���H��?8YA             @�D    �"D     �?          �?      node_count             nodes     �   ��������       ����                      ����                            ����                           ���                           ���                           ���	                           ���
                           ���            	               ���            
               ���                           ���                                 ���                           ���                           ���                                 ����                                           conn_count              conns               node_paths              editable_instances              version             RSRC�[remap]

path="res://.godot/exported/133200997/export-c48983f56782aa5ce9bcacbe3367d940-Block.scn"
�x��/78>��C�[remap]

path="res://.godot/exported/133200997/export-d267b47f7e81a3258979164d56d0d9c2-player.scn"
m&Skt8�(�[remap]

path="res://.godot/exported/133200997/export-3070c538c03ee49b7677ff960a3f5195-main.scn"
PR��s���խj�<svg height="128" width="128" xmlns="http://www.w3.org/2000/svg"><g transform="translate(32 32)"><path d="m-16-32c-8.86 0-16 7.13-16 15.99v95.98c0 8.86 7.13 15.99 16 15.99h96c8.86 0 16-7.13 16-15.99v-95.98c0-8.85-7.14-15.99-16-15.99z" fill="#363d52"/><path d="m-16-32c-8.86 0-16 7.13-16 15.99v95.98c0 8.86 7.13 15.99 16 15.99h96c8.86 0 16-7.13 16-15.99v-95.98c0-8.85-7.14-15.99-16-15.99zm0 4h96c6.64 0 12 5.35 12 11.99v95.98c0 6.64-5.35 11.99-12 11.99h-96c-6.64 0-12-5.35-12-11.99v-95.98c0-6.64 5.36-11.99 12-11.99z" fill-opacity=".4"/></g><g stroke-width="9.92746" transform="matrix(.10073078 0 0 .10073078 12.425923 2.256365)"><path d="m0 0s-.325 1.994-.515 1.976l-36.182-3.491c-2.879-.278-5.115-2.574-5.317-5.459l-.994-14.247-27.992-1.997-1.904 12.912c-.424 2.872-2.932 5.037-5.835 5.037h-38.188c-2.902 0-5.41-2.165-5.834-5.037l-1.905-12.912-27.992 1.997-.994 14.247c-.202 2.886-2.438 5.182-5.317 5.46l-36.2 3.49c-.187.018-.324-1.978-.511-1.978l-.049-7.83 30.658-4.944 1.004-14.374c.203-2.91 2.551-5.263 5.463-5.472l38.551-2.75c.146-.01.29-.016.434-.016 2.897 0 5.401 2.166 5.825 5.038l1.959 13.286h28.005l1.959-13.286c.423-2.871 2.93-5.037 5.831-5.037.142 0 .284.005.423.015l38.556 2.75c2.911.209 5.26 2.562 5.463 5.472l1.003 14.374 30.645 4.966z" fill="#fff" transform="matrix(4.162611 0 0 -4.162611 919.24059 771.67186)"/><path d="m0 0v-47.514-6.035-5.492c.108-.001.216-.005.323-.015l36.196-3.49c1.896-.183 3.382-1.709 3.514-3.609l1.116-15.978 31.574-2.253 2.175 14.747c.282 1.912 1.922 3.329 3.856 3.329h38.188c1.933 0 3.573-1.417 3.855-3.329l2.175-14.747 31.575 2.253 1.115 15.978c.133 1.9 1.618 3.425 3.514 3.609l36.182 3.49c.107.01.214.014.322.015v4.711l.015.005v54.325c5.09692 6.4164715 9.92323 13.494208 13.621 19.449-5.651 9.62-12.575 18.217-19.976 26.182-6.864-3.455-13.531-7.369-19.828-11.534-3.151 3.132-6.7 5.694-10.186 8.372-3.425 2.751-7.285 4.768-10.946 7.118 1.09 8.117 1.629 16.108 1.846 24.448-9.446 4.754-19.519 7.906-29.708 10.17-4.068-6.837-7.788-14.241-11.028-21.479-3.842.642-7.702.88-11.567.926v.006c-.027 0-.052-.006-.075-.006-.024 0-.049.006-.073.006v-.006c-3.872-.046-7.729-.284-11.572-.926-3.238 7.238-6.956 14.642-11.03 21.479-10.184-2.264-20.258-5.416-29.703-10.17.216-8.34.755-16.331 1.848-24.448-3.668-2.35-7.523-4.367-10.949-7.118-3.481-2.678-7.036-5.24-10.188-8.372-6.297 4.165-12.962 8.079-19.828 11.534-7.401-7.965-14.321-16.562-19.974-26.182 4.4426579-6.973692 9.2079702-13.9828876 13.621-19.449z" fill="#478cbf" transform="matrix(4.162611 0 0 -4.162611 104.69892 525.90697)"/><path d="m0 0-1.121-16.063c-.135-1.936-1.675-3.477-3.611-3.616l-38.555-2.751c-.094-.007-.188-.01-.281-.01-1.916 0-3.569 1.406-3.852 3.33l-2.211 14.994h-31.459l-2.211-14.994c-.297-2.018-2.101-3.469-4.133-3.32l-38.555 2.751c-1.936.139-3.476 1.68-3.611 3.616l-1.121 16.063-32.547 3.138c.015-3.498.06-7.33.06-8.093 0-34.374 43.605-50.896 97.781-51.086h.066.067c54.176.19 97.766 16.712 97.766 51.086 0 .777.047 4.593.063 8.093z" fill="#478cbf" transform="matrix(4.162611 0 0 -4.162611 784.07144 817.24284)"/><path d="m0 0c0-12.052-9.765-21.815-21.813-21.815-12.042 0-21.81 9.763-21.81 21.815 0 12.044 9.768 21.802 21.81 21.802 12.048 0 21.813-9.758 21.813-21.802" fill="#fff" transform="matrix(4.162611 0 0 -4.162611 389.21484 625.67104)"/><path d="m0 0c0-7.994-6.479-14.473-14.479-14.473-7.996 0-14.479 6.479-14.479 14.473s6.483 14.479 14.479 14.479c8 0 14.479-6.485 14.479-14.479" fill="#414042" transform="matrix(4.162611 0 0 -4.162611 367.36686 631.05679)"/><path d="m0 0c-3.878 0-7.021 2.858-7.021 6.381v20.081c0 3.52 3.143 6.381 7.021 6.381s7.028-2.861 7.028-6.381v-20.081c0-3.523-3.15-6.381-7.028-6.381" fill="#fff" transform="matrix(4.162611 0 0 -4.162611 511.99336 724.73954)"/><path d="m0 0c0-12.052 9.765-21.815 21.815-21.815 12.041 0 21.808 9.763 21.808 21.815 0 12.044-9.767 21.802-21.808 21.802-12.05 0-21.815-9.758-21.815-21.802" fill="#fff" transform="matrix(4.162611 0 0 -4.162611 634.78706 625.67104)"/><path d="m0 0c0-7.994 6.477-14.473 14.471-14.473 8.002 0 14.479 6.479 14.479 14.473s-6.477 14.479-14.479 14.479c-7.994 0-14.471-6.485-14.471-14.479" fill="#414042" transform="matrix(4.162611 0 0 -4.162611 656.64056 631.05679)"/></g></svg>
	   ��X��)4   res://Objects/Block.tscn��%'�19R   res://Player/player.tscn:��^~   res://textures/d_shadow_1.png�g�%�Bq   res://icon.svg똳��*   res://main.tscn9�B���ECFG
      application/config/name         Fps Test   application/run/main_scene         res://main.tscn    application/config/features$   "         4.0    Forward Plus       application/config/icon         res://icon.svg     input/forward�              deadzone      ?      events              InputEventKey         resource_local_to_scene           resource_name             device     ����	   window_id             alt_pressed           shift_pressed             ctrl_pressed          meta_pressed          pressed           keycode           physical_keycode   W   	   key_label             unicode    w      echo          script      
   input/back�              deadzone      ?      events              InputEventKey         resource_local_to_scene           resource_name             device     ����	   window_id             alt_pressed           shift_pressed             ctrl_pressed          meta_pressed          pressed           keycode           physical_keycode   S   	   key_label             unicode    s      echo          script      
   input/left�              deadzone      ?      events              InputEventKey         resource_local_to_scene           resource_name             device     ����	   window_id             alt_pressed           shift_pressed             ctrl_pressed          meta_pressed          pressed           keycode           physical_keycode   A   	   key_label             unicode    a      echo          script         input/right�              deadzone      ?      events              InputEventKey         resource_local_to_scene           resource_name             device     ����	   window_id             alt_pressed           shift_pressed             ctrl_pressed          meta_pressed          pressed           keycode           physical_keycode   D   	   key_label             unicode    d      echo          script         input/escape�              deadzone      ?      events              InputEventKey         resource_local_to_scene           resource_name             device     ����	   window_id             alt_pressed           shift_pressed             ctrl_pressed          meta_pressed          pressed           keycode           physical_keycode    @ 	   key_label             unicode           echo          script      
   input/duck�              deadzone      ?      events              InputEventKey         resource_local_to_scene           resource_name             device     ����	   window_id             alt_pressed           shift_pressed             ctrl_pressed          meta_pressed          pressed           keycode           physical_keycode    @ 	   key_label             unicode           echo          script      P��w(�