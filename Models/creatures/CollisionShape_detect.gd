extends Area3D

@export var damage := 1;
@export var stun_chance := 20;

signal body_part_hit(dam,stun_c)

func hit():
	emit_signal("body_part_hit", damage, stun_chance)
