extends Node
@onready var getSprite: AnimatedSprite2D = $"."
@export var startGameScene : PackedScene
func _ready():
	var tween = get_tree().create_tween()
	tween.tween_property(getSprite, "modulate", Color.WHITE, 1.5).set_ease(Tween.EASE_IN)

func _on_animation_start_timeout() -> void:
	getSprite.play()
	$"../AudioStreamPlayer2D".play()

func _on_change_scenes_timeout() -> void:
	get_tree().change_scene_to_file(startGameScene.resource_path)

func _on_animation_looped() -> void:
	getSprite.stop()
	$"../Change Scenes".start()
	
	var tween = get_tree().create_tween()
	tween.tween_property(getSprite, "modulate", Color(1,1,1,0),1.5).set_delay(1).set_ease(Tween.EASE_OUT)
