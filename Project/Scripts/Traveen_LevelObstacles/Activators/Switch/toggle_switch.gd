extends Switch

# Toggle between on and off
func use_switch() -> void:
	switchState = !switchState
	
	match (switchState):
		true:
			animation_player.play("SwitchOn")
		false:
			animation_player.play("SwitchOff")
