extends Node3D
@onready var environ = $WorldEnvironment
@export var env_lsd : Environment
@onready var world_light = $DirectionalLight3D

var pause = false
var start_white = Color("WHITE");
var start_energy = 2.0;

# Called when the node enters the scene tree for the first time.
func _ready():
	environ.environment = env_lsd;
	#process_mode = Node.PROCESS_MODE_ALWAYS;

func _process (delta) :
	pass
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
	
	

	
