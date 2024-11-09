extends Node3D

@export 	var env_lsd : Environment
@export var aud_amb_vol_mod = 0.75

@onready var environ = $WorldEnvironment
@onready var districts = $districts
@onready var world_lights = $world_lights
@onready var district_audio = $district_BG_audio
@onready var district_audio_2 = $district_BG_audio2
@onready var vis_map = $overhead_map

var player
var pause = false
var start_white = Color("WHITE");
var start_energy = 2.0;

var NPC_array = []
var district_array = []
var light_array = []
var NPC_int = 0;
var district_int = 0
var district_tag = false
var crossfade = false
var crossfade_step = 0;
var fade_token = -1
var env_inst = null
var light_inst = null

var tele_load = true
var tele_load_target = 0

var NPC_talk_reset_range = 20.0
var NPC_sleep_range = 70.0
var NPC_disappear_range = 70.0

var aud_db_1 = 0;
var aud_db_2 = 0;
var aud_db_int = 1.0/80.0;

var audio_override = false

signal set_particle(type)
var environ_shift
#light color
#light strength
#light position (later)
#fog strength
#fog color 
#make a default so if not near ANY nodes, we go to that node


# Called when the node enters the scene tree for the first time.
func _ready():
	player = $"/root/global".player
	player.blink_anim.animation_finished.connect(shift_environ)
	player.click_teleport.connect(teleport_audio_shift)
	player.fade_env_shif_override.connect(fade_env_shif_override)
	vis_map.visible = false
	environ.environment = env_lsd;
	#process_mode = Node.PROCESS_MODE_ALWAYS;
	district_array = districts.get_children(false)
	light_array = world_lights.get_children(false)
	NPC_array = $NPCs.get_children(false)
	#this is a really stupid way to preload shadow maps for lights
	#I'm 90% certain there's as better way 
	for n in light_array.size()-1:
			light_array[n].visible = true;
	for n in light_array.size()-1:
			light_array[n].visible = false;
	light_array[0].visible = true;
	district_audio.stream = load(district_array[0].audio)
	district_audio.volume_db = 0.0
	district_audio.play(randf_range(0.0,district_audio.stream.get_length()))
	env_inst = district_array[0].environ_info
	light_inst = district_array[0].light
	
func shift_environ() -> void:
	if fade_token != -1 :
		player.blink_anim.play()
		for n in light_array.size()-1:
			light_array[n].visible = false;
		district_array[fade_token].light.visible = true;
		environ.set_environment(district_array[fade_token].environ_info)
		fade_token = -1

func fade_env_shif_override() -> void:
	var d_token = 0;
	var top_range = 2999.0;
	for n in district_array.size()-1:
		var p_test = district_array[n].get_child(0);
		var _radius = p_test.mesh.radius * district_array[n].scale.y;
		var _dist = district_array[n].global_position.distance_to($"/root/global".player.global_position)
		if _dist < _radius :
			if _dist < top_range :
				top_range = _dist
				d_token = n
	if env_inst != district_array[d_token].environ_info || light_inst != district_array[d_token].light : 
		crossfade = true;
		crossfade_step = 0;
		env_inst = district_array[d_token].environ_info
		light_inst = district_array[d_token].light
	else :
		crossfade = true
		crossfade_step = 1
	
		

func teleport_audio_shift(audio) -> void:
	pass

func _process (delta) :
	
	if tele_load :
		if tele_load_target < district_array.size() :
			if player.global_position != district_array[tele_load_target].global_position :
				player.global_position.x = move_toward(player.global_position.x,district_array[tele_load_target].global_position.x,10.0);
				player.global_position.y = move_toward(player.global_position.y,district_array[tele_load_target].global_position.y,10.0);
				player.global_position.z = move_toward(player.global_position.z,district_array[tele_load_target].global_position.z,10.0);
			else :
				tele_load_target += 1
		else :
			Dialogic.start("timeline_null_reset") #this preloads the dialogic system
			player.global_position = $player_spawn_1.global_position
			player.teleload = false
			player.blink_anim.play()
			tele_load = false
			$loading_screen.visible = false
		
	
	#NPC talk, sleep, and disappear toggle check 
	var npc_dist = NPC_array[NPC_int].global_position.distance_to($"/root/global".player.global_position)
	#reset talk timer if outside talk range
	if npc_dist > NPC_talk_reset_range :
		NPC_array[NPC_int].talk_timer = false;
		NPC_array[NPC_int].f_timer = 0;
		NPC_array[NPC_int].dia_finished = false
	#if outside sleep range, is ready to sleep, go to sleep
	if npc_dist > NPC_sleep_range :
		if NPC_array[NPC_int].is_sleep == true :
			if NPC_array[NPC_int].fully_asleep == false :
				NPC_array[NPC_int].set_sleepmode = true
	#if seen by player while sleeping, set disappear to true 
	if npc_dist < NPC_sleep_range*0.5 :
		if NPC_array[NPC_int].fully_asleep == true :
			NPC_array[NPC_int].disappear = true
	#if outside disappear range & disappear set to true, move position
	if npc_dist > NPC_disappear_range :
		if NPC_array[NPC_int].disappear == true :
			NPC_array[NPC_int].gone = true
			NPC_array[NPC_int].global_transform.origin.y = -200;
	
	
	NPC_int += 1;
	if NPC_int > NPC_array.size() -1 :
		NPC_int = 0;
	
	#player environment check

	#if environment changed, do environment change behavior 

	var p_test = district_array[district_int].get_child(0);
	var _radius = p_test.mesh.radius * district_array[district_int].scale.y;
	if district_tag == false :
		var _dist = district_array[district_int].global_position.distance_to($"/root/global".player.global_position)
		if _dist < _radius :
			if district_array[district_int].audio != null :
				#if district_audio.stream != load(district_array[district_int].audio) :
					if env_inst != district_array[district_int].environ_info || light_inst != district_array[district_int].light :
						crossfade = true;
						crossfade_step = 0;
						env_inst = district_array[district_int].environ_info
						light_inst = district_array[district_int].light
					else :
						crossfade = true
						crossfade_step = 1


	
	if crossfade :
		# dump current audio into second stream, cloning position, volume, etc
		# load new audio into active stream
		# fade behaviors
		# stop playing second stream once it reaches vol 0
		if crossfade_step == 0 :
			var _pbp = district_audio.get_playback_position()
			district_audio_2.stream = district_audio.stream
			district_audio_2.play(_pbp)
			district_audio.stream = load(district_array[district_int].audio)
			var _aud_vol_a = district_audio.volume_db;
			var _aud_vol_b = district_audio_2.volume_db;
			district_audio.volume_db = _aud_vol_b;
			district_audio_2.volume_db = _aud_vol_a;
			district_audio.play(_pbp)
			environ_shift = district_array[district_int]
			crossfade_step = 1;
			player.blink_anim.play_backwards()
			fade_token = district_int
		if crossfade_step == 1 :
			if district_audio_2.volume_db > -80.0 :
				district_audio_2.volume_db -= 0.5 
			var amb_vol = 80.0 - (80.0*aud_amb_vol_mod);
			if district_audio.volume_db < 0.0 - amb_vol :
				district_audio.volume_db += 0.5
			#tween light color and energy
			#world_light.set_color(lerp(world_light.light_color,environ_shift.light_color,0.01));
			#world_light.light_energy = lerp(world_light.light_energy,environ_shift.light_strength,0.01)
			#tween BG energy mult
			#var e_set = lerp(environ.get_environment().background_energy_multiplier,environ_shift.environ_info.background_energy_multiplier,0.01);
			#environ.get_environment().set_bg_energy_multiplier(e_set)
			#tween fog light energy
			#e_set = lerp(environ.get_environment().fog_light_energy,environ_shift.environ_info.fog_light_energy,0.01);
			#environ.get_environment().set_fog_light_energy(e_set)
			#tween fog density
			#e_set = lerp(environ.get_environment().fog_density,environ_shift.environ_info.fog_density,0.01);
			#environ.get_environment().set_fog_density(e_set)
			#tween fog light color
			#e_set = lerp(environ.get_environment().fog_light_color,environ_shift.environ_info.fog_light_color,0.01);
			#environ.get_environment().set_fog_light_color(e_set)
			#crossfade = false
			#crossfade_step = 0

	district_int += 1;
	if district_int > district_array.size() -1 :
		district_int = 0;
	#if Input.is_action_pressed("escape"):
			#if pause :
			#	get_tree().paused = false
			#else:
				#get_tree().paused = true
			#pause = !pause
			
	#it sounds shitty but I guess you'll have to manually interpolate between the environment areas
	#for both light (directional lighting) & environment variables 
	#var color_a = Color("BLACK");
	#>>>>>>>>>> you're here
	#start_white = lerp(start_white,Color("BLACK"),0.01);
	#start_energy = lerp(start_energy,0.0,0.01);
	#world_light.set_color(start_white); #= start_white;
	#world_light.light_energy = start_energy;
	#change fog color
	#change fog light energy
	
	

	
