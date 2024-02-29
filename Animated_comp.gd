extends MeshInstance3D

@onready var anim_sprite = $AnimatedSprite3D
@onready var audio_stream = $AudioStreamPlayer3D
@onready var audio_stream2 = $AudioStreamPlayer3D2

# Called when the node enters the scene tree for the first time.
func _ready():
	anim_sprite.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_player_comp_clicked_signal():
	anim_sprite.visible = true
	audio_stream.play()
	audio_stream2.play()
