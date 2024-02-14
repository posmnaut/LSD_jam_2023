extends Node3D
class_name door

@onready var door_vis = $r_point
@onready var swing = false;
@onready var swing_direction = 0;
@onready var base_rotation;

var swing_state = 0;
var open_int = 100;
var open_timer = 0;
var open_time = 5*60;
var swing_speed = 0.06

# Called when the node enters the scene tree for the first time.
func _ready():
	base_rotation = rotation.y;


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if swing :
		if swing_state == 0 :
			if swing_direction > 0 :
				swing_state = 1
			else :
				swing_state = 2
		if swing_state == 1 :
			door_vis.rotation.y = move_toward(door_vis.rotation.y,deg_to_rad(base_rotation-90.0),swing_speed)
			if door_vis.rotation.y < deg_to_rad(base_rotation-90.0)+0.01 :
				swing_state = 3
		if swing_state == 2 :
			door_vis.rotation.y = move_toward(door_vis.rotation.y,deg_to_rad(base_rotation+90.0),swing_speed)
			if door_vis.rotation.y > deg_to_rad(base_rotation+90.0)-0.01 :
				swing_state = 3
		if swing_state == 3 :
			open_timer += open_int*delta;
			if open_timer > open_time :
				door_vis.rotation.y = move_toward(door_vis.rotation.y,deg_to_rad(base_rotation),swing_speed)
				if snapped(door_vis.rotation.y,0.001) == snapped(deg_to_rad(base_rotation),0.001) :
					swing_state = 0
					swing = false
					open_timer = 0
