extends CharacterBody3D

var player = null;
var state_machine;
var nav_token = 0;
var health = 10;
var hp_bar_timer = 0;

const SPEED = 4.0;
const ATTACK_RANGE = 2.5;


@onready var player_path := $"../Player_v2"

@onready var nav_agent = $NavigationAgent3D;
@onready var anim_tree = $AnimationTree
@onready var anim = $AnimationPlayer
@onready var arma = $Armature
@onready var area_3d = $player_area_detection
@onready var hp_bar = $SubViewport/HP_bar_3d
@onready var pathing_collider = $CollisionShape3D

func _ready():
	player = player_path
	state_machine = anim_tree.get("parameters/playback");
	anim_tree.set("parameters/conditions/run", true);
	hp_bar.visible = false;
	
	
func _process(_delta):
	
	velocity = Vector3.ZERO;
	#anim_tree.set("parameters/conditions/stagger", false)
	
	if hp_bar_timer > 0 :
		hp_bar_timer -= 1
		if hp_bar_timer == 1 :
			hp_bar.visible = false
	
	match state_machine.get_current_node(): #this checks if thing is thing and does thing accordingly
		"p_zom_1_run_1":
			#navigation
			#set targ pos sends a request to the nav server for pathfinding
			#since the navserver is a black box, I think, staggering requests from 
			#enemies should do the trick, as the nav server *is* multithreaded 
			# token system should do the trick
			nav_agent.set_target_position(player.global_transform.origin);
			var next_nav_point = nav_agent.get_next_path_position();
			velocity = (next_nav_point - global_transform.origin).normalized() * SPEED;
			look_at(Vector3(player.global_position.x+velocity.x,player.global_position.y,
							player.global_position.z+velocity.z), Vector3.UP);
		"p_zom_1_atk_1":
			look_at(Vector3(player.global_position.x,player.global_position.y,player.global_position.z), Vector3.UP)
		"p_zom_1_stmbl_1":
			anim_tree.set("parameters/conditions/stagger", false)

	
	#conditions
	anim_tree.set("parameters/conditions/attack", _target_in_range());
	#anim_tree.set("parameters/conditions/run", !_target_in_range());
	
	move_and_slide();

func _target_in_range():
	#note: layer 1, mask 3. means it's on layer 1 but scan for stuff on layer 2 AKA the player
	#note: later, move this behavior into the PLAYER so there's less calls happening per frame 
	#print(area_3d.has_overlapping_areas());
	#return global_position.distance_to(player.global_position) < ATTACK_RANGE;
	return area_3d.has_overlapping_areas();


func _on_timer_timeout():
	arma.visible = true;
	
func _hit_finished():
	if global_position.distance_to(player.global_position) < ATTACK_RANGE + 1.0:
		var dir = global_position.direction_to(player.global_position)
		player._hit(dir);


func _on_area_3d_body_part_hit(dam, stun_c):
		health -= dam
		
		#change this to be pseudo-random, as well as NOT use such big numbers 
		var ran = randi_range(stun_c,100)
		if ran == 100:
			anim_tree.set("parameters/conditions/stagger", true)
		
		#update HP bar visual
		#i'm sure there's a smarter way to handle this timer behavior 
		hp_bar_timer = 120
		hp_bar.visible = true
		
		if hp_bar.value < dam*10 :
			dam = hp_bar.value
		hp_bar.value -= dam*10
		
		
		if health <= 0:
			pathing_collider.disabled = true
			anim_tree.set("parameters/conditions/die", true)
			hp_bar.visible = false
			await get_tree().create_timer(4.0).timeout
			queue_free() 
