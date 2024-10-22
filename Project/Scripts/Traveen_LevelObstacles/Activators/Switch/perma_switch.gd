extends Switch

# Toggle on and keep it on
func use_switch() -> void:
	if switchState == false:
		switchState = true
