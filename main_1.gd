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
	vis_map.visible = false
	environ.environment = env_lsd;
	#process_mode = Node.PROCESS_MODE_ALWAYS;
	district_array = districts.get_children(false)
	light_array = world_lights.get_children(false)
	NPC_array = $NPCs.get_children(false)
	#this is a really stupid way to preload shadow maps for lights
	#I'm 90% certain there's as better way 
	for n in 3:
			light_array[n].visible = true;
	for n in 3:
			light_array[n].visible = false;
	light_array[0].visible = true;
	district_audio.stream = load(district_array[0].audio)
	district_audio.volume_db = 0.0
	district_audio.play(randf_range(0.0,district_audio.stream.get_length()))
	
func shift_environ() -> void:
	if fade_token != -1 :
		player.blink_anim.play()
		for n in 3:
			light_array[n].visible = false;
		light_array[fade_token].visible = true;
		environ.set_environment(district_array[fade_token].environ_info)
		fade_token = -1

func teleport_audio_shift(audio) -> void:
	if audio_override :
		audio_override = false
		var _pbp = district_audio.get_playback_position()
		var _stream_store = district_audio_2.stream
		district_audio_2.stream = district_audio.stream
		district_audio_2.play(_pbp)
		district_audio.stream = _stream_store
		var _aud_vol_a = district_audio.volume_db;
		var _aud_vol_b = district_audio_2.volume_db;
		district_audio.volume_db = _aud_vol_b;
		district_audio_2.volume_db = _aud_vol_a;
		district_audio.play(_pbp)
		crossfade_step = 1;
	else :
		audio_override = true
		var _pbp = district_audio.get_playback_position()
		district_audio_2.stream = district_audio.stream
		district_audio_2.play(_pbp)
		district_audio.stream = load(audio) #get this from door
		var _aud_vol_a = district_audio.volume_db;
		var _aud_vol_b = district_audio_2.volume_db;
		district_audio.volume_db = _aud_vol_b;
		district_audio_2.volume_db = _aud_vol_a;
		district_audio.play(_pbp)
		crossfade_step = 1;

func _process (delta) :
	
	#NPC talk, sleep, and disappear toggle check 
	var npc_dist = NPC_array[NPC_int].global_position.distance_to($"/root/global".player.global_position)
	#reset talk timer if outside talk range
	if npc_dist > NPC_talk_reset_range :
		NPC_array[NPC_int].talk_timer = false;
		NPC_array[NPC_int].f_timer = 0;
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
	if audio_override == false :
		var p_test = district_array[district_int].get_child(0);
		var _radius = p_test.mesh.radius * district_array[district_int].scale.y;
		if district_tag == false :
			var _dist = district_array[district_int].global_position.distance_to($"/root/global".player.global_position)
			if _dist < _radius :
				if player.is_on_floor() :
					if district_array[district_int].audio != null :
						if district_audio.stream != load(district_array[district_int].audio) :
							crossfade = true;
							crossfade_step = 0;

	
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
	
	

	
