extends Node2D
class_name Spring
@export var bounceAmount = 50
@onready var animation_player: AnimationPlayer = $"../AnimationPlayer"

var resetAnimation = false
func BouncePlayer(player)-> void:
	animation_player.play("Bounce")
	player.velocity.y -= bounceAmount
	print("Bounce")
	resetAnimation = true

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	animation_player.play("Idle")
	resetAnimation = false
