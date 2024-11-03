class_name StateBaseClass
extends Node

var stateMachineRef = null

# Called when the node enters the scene tree for the first time.

#FOR: `_unhandled_input()`.
func handle_input(event: InputEvent) -> void:
	pass

#FOR: `_process()`.
func update(delta: float) -> void:
	pass

#FOR: `_physics_process()`.
func physics_update(delta: float) -> void:
	pass

#FOR: `StateMachine` to call when changing the current `active-state`. The ->
#-> `msg` parameter is a dictionary with arbitrary data the `State` can use to ->
#-> initialize istelf.
func enter(msg := {}) -> void:
	pass

#FOR: `StateMachine` to call before changing the `active-state`. Use this function ->
#-> to clean up the current state before swapping.
func exit() -> void:
	pass
