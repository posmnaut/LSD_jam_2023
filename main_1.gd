extends Node3D
@onready var environ = $WorldEnvironment
@export var env_lsd : Environment

# Called when the node enters the scene tree for the first time.
func _ready():
	environ.environment = env_lsd;
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
