extends Node3D
@onready var path = $".."
@onready var anim_player = $AnimationPlayer

var eatingFood = false
#var storePath = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	anim_player.play("swimming") # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(eatingFood == false):
		path.progress += 5*delta;


func _on_player_fish_eat():
	#storePath = path.progress
	path.progress = 0
	eatingFood = true
	anim_player.play("eating")
	


func _on_animation_player_animation_finished(anim_name):
	if(anim_name == "eating"):
		anim_player.play("swimming")
		eatingFood = false
