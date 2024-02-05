extends Node3D
@onready var path = $".."

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	path.progress += 5*delta;
	print(path.progress)
	pass
