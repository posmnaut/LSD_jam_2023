extends JournalState


# Called when the node enters the scene tree for the first time.
func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func update(delta: float):
	dreamJournal.anim_sprite.visible = true
	dreamJournal.anim_sprite.play("opening")
