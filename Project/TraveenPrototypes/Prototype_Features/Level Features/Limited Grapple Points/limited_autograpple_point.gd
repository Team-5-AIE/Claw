extends LimitedGrapplePoint

@onready var auto_collision: CollisionShape2D = $AutoGrappleArea/CollisionShape2D

func start_cooldown() -> void:
	active_collision.set_deferred("disabled", true)
	auto_collision.set_deferred("disabled", true)
	active_sprite.visible = false
	inactive_sprite.visible = true
	cooldown.start()

func _on_grapple_point_cooldown_timeout() -> void:
	active_collision.set_deferred("disabled", false)
	auto_collision.set_deferred("disabled", false)
	active_sprite.visible = true
	inactive_sprite.visible = false
