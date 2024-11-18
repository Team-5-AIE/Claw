extends Node2D
class_name Spring

@export var bounceAmount:float = 600
@export var bounceStopFraction:float = 0

var resetAnimation = false

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func BouncePlayer(player)-> void:
	animation_player.play("Bounce")
	player.velocity *= (1.0 - bounceStopFraction)
	player.velocity += Vector2.UP.rotated(rotation) * bounceAmount
	print("Bounce")
	resetAnimation = true

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	animation_player.play("Idle")
	resetAnimation = false

func _on_body_entered(body: Node2D) -> void:
	if body is SWPlatformerCharacter:
		if body.velocity.dot(Vector2.UP.rotated(rotation)) < 0:
			BouncePlayer(body)
