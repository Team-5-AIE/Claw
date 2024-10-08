extends CooldownGrapplePoint

@onready var auto_collision: CollisionShape2D = $AutoGrappleArea/CollisionShape2D

func start_cooldown() -> void:
	auto_collision.set_deferred("disabled", true)
	super()

func _on_grapple_point_cooldown_timeout() -> void:
	auto_collision.set_deferred("disabled", false)
	super()
