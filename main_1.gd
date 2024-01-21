extends Node3D
@onready var environ = $WorldEnvironment
@export var env_lsd : Environment

# Called when the node enters the scene tree for the first time.
func _ready():
	environ.environment = env_lsd;
