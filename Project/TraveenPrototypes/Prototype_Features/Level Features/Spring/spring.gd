extends Area2D

@export var springStrength: float = 350
@export_range(-90, 90) var launchAngle: float = 0
@export_range(0, 1) var launchStopFraction: float = 0.8

var launchDirection: Vector2

func _ready() -> void:
	launchDirection = Vector2.UP.rotated(self.rotation + deg_to_rad(launchAngle))

func _on_body_entered(body: Node2D) -> void:
	if body is SWPlatformerCharacter:
		body.velocity *= 1 - launchStopFraction
		body.velocity += launchDirection * springStrength
		if body.finite_state_machine.state != body.state_spear:
			body.finite_state_machine.ChangeState(body.state_fall)
