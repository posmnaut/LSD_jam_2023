extends Node3D

const speed = 40.0;

@onready var mesh = $MeshInstance3D
@onready var ray_cast = $RayCast3D
@onready var particles = $GPUParticles3D
@onready var hit_audio = $hit_audio

func _ready():
	pass
	

func _process(delta):
	position += transform.basis * Vector3(0,0,-speed) * delta;
	if ray_cast.is_colliding():
		mesh.visible = false;
		particles.emitting = true;
		ray_cast.enabled = false;
		
		if ray_cast.get_collider().is_in_group("enemy"):
			ray_cast.get_collider().hit()
			
		hit_audio.play()
		await get_tree().create_timer(1.0).timeout
		queue_free()
		


func _on_timer_timeout():
	queue_free()
