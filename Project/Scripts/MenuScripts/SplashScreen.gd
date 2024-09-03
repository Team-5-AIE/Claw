extends Node
@onready var getSprite: AnimatedSprite2D = $"."
@onready var getrect: ColorRect = $"../Control/CanvasLayer/ColorRect"


func _ready():
	var tween = get_tree().create_tween()
	tween.tween_property(getrect, "color", Color8(218, 134, 62, 255), 1.3)
	tween.tween_property(getSprite, "modulate", Color.WHITE, 1).set_ease(Tween.EASE_IN)
	
	var fade_tween = get_tree().create_tween()
	fade_tween.tween_property($"../Control/CanvasLayer/Label","modulate", Color.TRANSPARENT, 0.5).set_delay(1).set_ease(Tween.EASE_OUT)

func _on_animation_start_timeout() -> void:
	getSprite.play()
	$"../AudioStreamPlayer2D".play()

func _on_change_scenes_timeout() -> void:
	get_tree().change_scene_to_file("res://Rooms/main_menu.tscn")

func _on_animation_looped() -> void:
	getSprite.stop()
	$"../Change Scenes".start()
	
	var tween = get_tree().create_tween()
	tween.tween_property(getSprite, "modulate", Color.TRANSPARENT,1.5).set_delay(1).set_ease(Tween.EASE_OUT)
	
	var tween2 = get_tree().create_tween()
	tween2.tween_property(getrect, "color", Color8(9,10,20,255), 1.8).set_delay(1).set_ease(Tween.EASE_OUT)
	
func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.keycode == KEY_SPACE && event.is_pressed():
			print("Skipped")
			get_tree().change_scene_to_file("res://Rooms/main_menu.tscn")
