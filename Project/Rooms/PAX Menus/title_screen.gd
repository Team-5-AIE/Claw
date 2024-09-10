extends MarginContainer

@export var chapterScreen : Control
@export var creditsScreen : Control

func _input(event: InputEvent) -> void:
	if self.visible == true and event.is_pressed():
		chapterScreen.visible = true
		self.visible = false

func _on_credits_button_pressed() -> void:
	creditsScreen.visible = true
	chapterScreen.visible = false

func _on_credits_return_button_pressed() -> void:
	chapterScreen.visible = true
	creditsScreen.visible = false
