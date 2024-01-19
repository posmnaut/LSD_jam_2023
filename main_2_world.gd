extends Node3D

@onready var spawns = $enem_spawn
@onready var navigation_region = $NavigationRegion3D
@onready var hit_rect = $UI/ColorRect

var zombie = load("res://Models/creatures/zombie_exp_test_1_5_anim.tscn")
var instance

func _ready():
	randomize()

func _get_random_child(parent_node):
	var random_id = randi() % parent_node.get_child_count();
	return parent_node.get_child(random_id);


func _on_zomb_spawn_timer_timeout():
	var spawn_point = _get_random_child(spawns).global_position
	instance = zombie.instantiate()
	instance.position = spawn_point
	#set nav token
	instance.nav_token = 0;
	navigation_region.add_child(instance)


func _on_player_v_2_player_hit():
	#to connect signals, click on the emitter object, nodes (top right), double click, then the
	# object / node it's connecting to 
	hit_rect.visible = true;
	await get_tree().create_timer(0.2).timeout
	hit_rect.visible = false
