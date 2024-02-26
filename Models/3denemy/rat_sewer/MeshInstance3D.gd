extends MeshInstance3D

var speed = 0.05

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	get_active_material(0).uv1_offset.y += delta*speed;
	if get_active_material(0).uv1_offset.y >= 1 :
		get_active_material(0).uv1_offset.y = 0.0;
