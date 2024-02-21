extends Node3D
@export var target : Node
@onready var target_point
@onready var mesh = $Area3D/CollisionShape3D/MeshInstance3D
@export var audio = ""

# Called when the node enters the scene tree for the first time.
func _ready():
	target_point = target
	mesh.visible = false
	target.visible = false
