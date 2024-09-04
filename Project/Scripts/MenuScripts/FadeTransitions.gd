extends CanvasLayer

signal on_fade_in_finished
signal on_fade_out_finished

@onready var color_rect: ColorRect = $ColorRect
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var lockPlayer = false

var restart
func _ready():
	color_rect.visible = false
	animation_player.animation_finished.connect(_on_animation_finished)

func _on_animation_finished(anim_name):
	if anim_name == "FadeIn":
		on_fade_in_finished.emit()
		animation_player.play("FadeOut")
	elif anim_name == "FadeOut":
		on_fade_out_finished.emit()
		color_rect.visible = false
		
	#Restart
	elif anim_name == "FadeInRestart":
		on_fade_in_finished.emit()
		animation_player.play("FadeOutRestart")
	elif anim_name == "FadeOutRestart":
		on_fade_out_finished.emit()
		color_rect.visible = false


func Transition():
	lockPlayer = true
	color_rect.visible = true
	animation_player.play("FadeIn")

func TransitionRestart():
	lockPlayer = true
	color_rect.visible = true
	animation_player.play("FadeInRestart")
