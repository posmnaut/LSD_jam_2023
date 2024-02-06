extends Node3D

@export var audio = ""
@export var environ_info : Environment
@export var light_color : Color
@export_range(0, 16) var light_strength = 0.0

@onready var mesh = $MeshInstance3D

#light color is self explanatory (for directional light 3d)
#light strength is self explanatory (for directional light 3d)
#audio is self explanatory
#the following are loaded from the installed environment:
#background energy multiplier
#fog color
#fog light energy
#fog density

func _ready() :
	mesh.visible = false
