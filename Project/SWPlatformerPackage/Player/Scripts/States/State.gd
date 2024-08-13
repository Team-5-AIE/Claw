class_name State
extends Node

func EnterState() -> void:
	pass
	
func UpdatePhysics(_delta)-> void:  # Runs in _physics_process()
	pass

func Update(_delta)-> void:  # Runs in _process()
	pass

func Inputs(_event) -> void:  # Runs in _process()
	return

func ExitState() -> void:
	pass

