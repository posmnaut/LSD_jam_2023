@tool
extends MeshInstance3D

@export var cList:Array[Color] = []

var newtext:Gradient = Gradient.new()

func _ready():
	var newImg:GradientTexture1D = GradientTexture1D.new()
	newImg.gradient = gen_gradient()
	print(newImg.gradient.get_point_count())
	#material_override.set_shader_parameter("pal", newImg)
	pass

func gen_gradient() -> Gradient:
	#cList.clear()
	for i in newtext.get_point_count()-1:
		newtext.remove_point(0)

	newtext.interpolation_mode = Gradient.GRADIENT_INTERPOLATE_CONSTANT

	for i in cList.size():
		newtext.add_point(i/16.0, cList[i])
	
	
	newtext.remove_point(0)
	return newtext
