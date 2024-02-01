extends Node3D
@onready var environ = $WorldEnvironment
@export 	var env_lsd : Environment
@onready var world_light = $DirectionalLight3D_day
@onready var districts = $districts
@onready var district_audio = $district_BG_audio
@onready var district_audio_2 = $district_BG_audio2

var pause = false
var start_white = Color("WHITE");
var start_energy = 2.0;

var district_array = []
var district_int = 0
var district_tag = false
var crossfade = false
var crossfade_step = 0;

var aud_db_1 = 0;
var aud_db_2 = 0;
var aud_db_int = 1/80;

var environ_shift
#light color
#light strength
#light position (later)
#fog strength
#fog color 
#make a default so if not near ANY nodes, we go to that node


# Called when the node enters the scene tree for the first time.
func _ready():
	environ.environment = env_lsd;
	#process_mode = Node.PROCESS_MODE_ALWAYS;
	district_array = districts.get_children(false)
	
	

func _process (delta) :
	
	#player environment check
	#if environment changed, do environment change behavior 
	
	var p_test = district_array[district_int].get_child(0);
	var _radius = p_test.mesh.radius * district_array[district_int].scale.y;
	if district_tag == false :
		var _dist = district_array[district_int].global_position.distance_to($"/root/global".player.global_position)
		if _dist < _radius :
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
		if crossfade_step == 1 :
			if district_audio_2.volume_db > -80.0 :
				district_audio_2.volume_db -= 0.5 
			if district_audio.volume_db < 0.0 :
				district_audio.volume_db += 0.5
			#tween light color and energy
			world_light.set_color(lerp(world_light.light_color,environ_shift.light_color,0.01));
			world_light.light_energy = lerp(world_light.light_energy,environ_shift.light_strength,0.01)
			#tween BG energy mult
			var e_set = lerp(environ.get_environment().background_energy_multiplier,environ_shift.environ_info.background_energy_multiplier,0.01);
			environ.get_environment().set_bg_energy_multiplier(e_set)
			#tween fog light energy
			e_set = lerp(environ.get_environment().fog_light_energy,environ_shift.environ_info.fog_light_energy,0.01);
			environ.get_environment().set_fog_light_energy(e_set)
			#tween fog density
			e_set = lerp(environ.get_environment().fog_density,environ_shift.environ_info.fog_density,0.01);
			environ.get_environment().set_fog_density(e_set)
			#tween fog light color
			e_set = lerp(environ.get_environment().fog_light_color,environ_shift.environ_info.fog_light_color,0.01);
			environ.get_environment().set_fog_light_color(e_set)
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
	
	

	
