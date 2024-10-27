extends Switch

@export var initialState: bool = false

func _ready() -> void:
	switchState = initialState

# Toggle between on and off
func use_switch() -> void:
	switchState = !switchState
