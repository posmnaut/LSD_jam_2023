extends CharacterBody3D


@onready var anim_player = $AnimationPlayer
@onready var direct_cast = $DirectionCast

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
var gravity = 30
var direction = Vector3.FORWARD

func _ready():
	anim_player.play("patrol")


func _physics_process(delta):
	
	#if(anim_player.current_animation_position >= 2.0 && anim_player.current_animation_position <= 2.05 || anim_player.current_animation_position >= 6.7 && anim_player.current_animation_position <= 6.75):
		#var preDirection = direction
		#var tempDirection = Vector3(randf_range(-1, 1), 0, randf_range(-1, 1)).normalized() * 5
		#
		#var preCast = direct_cast
		#direct_cast.look_at(tempDirection, Vector3.UP)
		#print(direct_cast.get_collider())
		#if(direct_cast.get_collider() != null):
			#var direction = tempDirection.normalized()
		#else:
			#direct_cast = preCast
			#direction = preDirection
			#
		#print(tempDirection)
	# Add the gravity.
	if not is_on_floor():
		#print(velocity.y)
		velocity.y -= 30 * delta

	if(anim_player.current_animation_position >= 2.0 && anim_player.current_animation_position <= 4.0):
		velocity.x = lerp(velocity.x, velocity.x + 0.025, 0.15)
		velocity.x = 0
		velocity.z = lerp(velocity.z, velocity.z - 0.025, 0.15)
	elif(anim_player.current_animation_position >= 6.7 && anim_player.current_animation_position <= 7.6):
		#velocity.x = direction.x * lerp(velocity.x, velocity.x + 1.5, 0.35)
		#velocity.z = direction.z * lerp(velocity.z, velocity.z - 1.5, 0.35)
		velocity.x = lerp(velocity.x, velocity.x + 0.05, 0.35)
		velocity.x = 0
		velocity.z = lerp(velocity.z, velocity.z - 0.05, 0.35)
	#elif(anim_player.current_animation_position < 8.0 && anim_player.current_animation_position > 6.0):
		#velocity.z = lerp(velocity.z, 0.0, 0.05)
	else:
		velocity.x = lerp(velocity.x, 0.0, 0.02)
		velocity.z = lerp(velocity.z, 0.0, 0.02)
	
	move_and_slide()
