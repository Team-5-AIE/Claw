extends Node
@onready var getSprite: AnimatedSprite2D = $"."
@onready var getrect: ColorRect = $"../Control/CanvasLayer/ColorRect"
@onready var label: RichTextLabel = $"../Control/CanvasLayer/Label"
@onready var sceneTimer: Timer = $"../Change Scenes"
@export var getScene: PackedScene

var start_tween : Tween
var text_tween : Tween
var fade_tween : Tween

func _ready():
	start_tween = get_tree().create_tween()
	start_tween.set_parallel(true)
	start_tween.tween_property(getrect, "color", Color8(218, 134, 62, 255), 1.3)
	start_tween.chain().tween_property(getSprite, "modulate", Color.WHITE, 1).set_ease(Tween.EASE_IN)

func _on_animation_start_timeout() -> void:
	getSprite.play()
	AudioManager.play_menu_sound(AudioManager.SPLASH_SCREEN, 0)

func _on_change_scenes_timeout() -> void:
	FadeTransitions.Transition()
	await FadeTransitions.on_fade_in_finished
	AudioManager.play_music(AudioManager.MUSIC_WOLF, 0)
	fade_tween.kill()
	text_tween.kill()
	get_tree().change_scene_to_file(getScene.resource_path)

func _on_animation_looped() -> void:
	getSprite.stop()
	if sceneTimer.is_stopped():
		_start_game()

func _input(event: InputEvent) -> void:
	if event.is_pressed() and sceneTimer.is_stopped():
		print("Skipped")
		text_tween = get_tree().create_tween()
		text_tween.tween_property(label,"modulate", Color.TRANSPARENT, 0.9).set_ease(Tween.EASE_OUT) 
		$"../Text Fade".stop() 
		_start_game()

func _start_game() -> void:
	start_tween.kill()
	fade_tween = get_tree().create_tween()
	fade_tween.set_parallel(true)
	fade_tween.tween_property(getSprite, "modulate", Color8(9,10,20,255),1.5).set_ease(Tween.EASE_OUT)
	fade_tween.tween_property(getSprite, "self_modulate", Color.TRANSPARENT,1.5).set_ease(Tween.EASE_OUT)
	fade_tween.tween_property(getrect, "color", Color8(9,10,20,255), 1.8).set_ease(Tween.EASE_OUT)
	
	sceneTimer.start()


func _on_text_fade_timeout() -> void:
	text_tween = get_tree().create_tween()
	text_tween.tween_property(label,"modulate", Color.TRANSPARENT, 0.9).set_ease(Tween.EASE_OUT)
