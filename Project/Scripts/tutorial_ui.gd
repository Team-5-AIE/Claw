extends AnimatedSprite2D

var using_keyboard: bool :
	set(value):
		if using_keyboard != value:
			using_keyboard = value
			_choose_animation()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	using_keyboard = Global.crosshair.isMouseUsed

func _choose_animation() -> void:
	match (using_keyboard):
		true:
			play("pc")
		false:
			play("xbox")
