extends Node

@onready var element: Control = self.get_parent()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	element.mouse_entered.connect(_on_mouse_entered)
	element.focus_entered.connect(_on_focus_entered)

func _on_mouse_entered() -> void:
	element.call_deferred("grab_focus")

func _on_focus_entered() -> void:
	AudioManager.play_menu_sound(AudioManager.HOOK1, 0)
	pass # Play menu button sound
