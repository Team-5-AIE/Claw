extends RichTextLabel

func _ready() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(self, "modulate", Color.TRANSPARENT, 1.5).set_ease(Tween.EASE_OUT)
	tween.tween_callback(_set_visibility)


func _on_finished() -> void:
	if self.visible == false:
		self.visible = true
		var tween = get_tree().create_tween()
		tween.tween_property(self, "modulate", Color.WHITE, 1.5).set_ease(Tween.EASE_IN)
		tween.tween_callback(_on_finished)
	else:
		var tween = get_tree().create_tween()
		tween.tween_property(self, "modulate", Color.TRANSPARENT, 1.5).set_ease(Tween.EASE_OUT)
		tween.tween_callback(_set_visibility)

func _set_visibility():
	self.visible = not self.visible
	_on_finished()
