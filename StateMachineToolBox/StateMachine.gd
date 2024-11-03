class_name StateMachine
extends Node

signal transitioned(state_name)

##Path to the initial active state. We export it to be able to picl the intial ->
##-> state in the inspector.
#@export var initial_state = NodePath()
#
##The current active state. At the start of the game, we get the `initial_state`.
#@onready var state: StateBaseClass = get_node(initial_state)

# Called when the node enters the scene tree for the first time.
func _ready():
	##await(owner, "ready")
	#
	##IMPORTANT NOTE: The `StateMachine` assigns itself to the `State` instance's ->
	##-> `state_machine` instance variable.
	#for child in get_children():
		#child.state_machine = self
	#state.enter()
	pass

##NOTE: The `StateMachine` subscribes to the Node callbacks and delegates them to ->
##-> the `State` instances (the current "active-state" instance).
#func _unhandled_input(event):
	#state.handle_input(event)
#
## Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
	#state.update(delta)
#
##func _physics_process(delta):
	##state.physics_update(delta)
#
##IMPORTANT NOTE: This functions calls the current "active-state"'s `State` instance ->
##-> function `exit()`, then changes the "active-state" to the new incoming `State` ->
##-> instance and calls its `enter()` `State` instance function.
#func transition_to(target_state_name: String, msg: Dictionary = {}) -> void:
	##NOTE: This is a safety check, you could use the `assert()` function here to ->
	##-> report an error if the `State`'s name is incorrect. We don't use the ->
	##-> `assert()` function here to help with code reuse. If you reuse a `State` ->
	##-> instance in a different `StateMachine` aswell (for example, using the ->
	##-> "journal" `State` in both the `PlayerStateMachine` and the ->
	##-> `JounralUIStateMachine` `State` machines), but you don't want all the `State`s, ->
	##-> they won't be able to transition to `State` instances that are not in the ->
	##-> current `SceneTree` for this `StateMachine`.
	#if(has_node(target_state_name) == false):
		#return
	#else:
		#state.exit()
		#state = get_node(target_state_name)
		#state.enter(msg)
		#transitioned.emit(target_state_name)
