class_name MovingBlock
extends StaticBody2D

var previous_position: Vector2 = Vector2.ZERO

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	constant_linear_velocity = (self.position - previous_position)/delta
	previous_position = self.position
