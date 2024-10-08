extends ObstacleKey

@onready var grapple_collision: CollisionShape2D = $GrapplePoint/CollisionShape2D

func _setup_key() -> void:
	grapple_collision.disabled = false
	super()

func _reset_key() -> void:
	grapple_collision.disabled = false
	super()

func _collect_key() -> void:
	grapple_collision.disabled = true
	super()

func delete_key() -> void:
	grapple_collision.disabled = true
	super()
