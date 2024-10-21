extends Switch

@export var switch_time_length: float = 10

@onready var switch_timer: Timer = $SwitchTimer

# Toggle on and start a timer
func use_switch() -> void:
	if switchState == false:
		switchState = true
	switch_timer.start(switch_time_length)

# When Timer finishes, turn off switch
func _on_switch_timer_timeout() -> void:
	switchState = false
