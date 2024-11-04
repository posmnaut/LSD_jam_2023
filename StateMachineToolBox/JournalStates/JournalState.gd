#IMPORTANT NOTE: This is a "boilerplate class" to allow us to have full ->
#-> autocompletion and type checks for the `Journal` instance when coding ->
#-> the `Journal`s `State`s. Without this, we have to run the game to see ->
#-> typos and other errors the compiler could otherwise catch while ->
#-> programming.
class_name JournalState
extends StateBaseClass

#Reference to the `Journal` instance:
@onready var dreamJournal: DreamJournalSM

# Called when the node enters the scene tree for the first time.
func _ready():
	#IMPORTANT NOTE: The `State` instances are children of the `DreamJournal` ->
	#-> instance (Node), so their `_ready()` instance functions will execute ->
	#-> first. That is why we wait for the `owner` (`DreamJournal`) to be ready ->
	#-> first.
	assert(owner, "ready")
	
	#The `as` keyword casts the `owner` variable to the `DreamJournal` type. If ->
	#-> the `owner` variable is not a `DreamJournal` instance, we will get ->
	#-> `null`, and know not to proceed.
	dreamJournal = owner as DreamJournalSM
	
	#This check will tell us if we inadvertently assign a derived `State` ->
	#-> Class in a `Scene` other than `DreamJournal.tscn`, which would be ->
	#-> unintended. This can help prevent some bugs that are difficult to ->
	#-> understand.
	assert(dreamJournal != null)


## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
	#pass
