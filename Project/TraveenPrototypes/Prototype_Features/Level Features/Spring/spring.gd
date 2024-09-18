extends Area2D

@export var springStrength: float = 350
@export_range(0, 1) var springStopFraction: float = 0.8

func _on_body_entered(body: Node2D) -> void:
	if body is SWPlatformerCharacter:
		body.velocity *= 1 - springStopFraction
		body.velocity += Vector2.UP.rotated(self.rotation) * springStrength
		if body.finite_state_machine.state != body.state_spear:
			body.finite_state_machine.ChangeState(body.state_fall)
