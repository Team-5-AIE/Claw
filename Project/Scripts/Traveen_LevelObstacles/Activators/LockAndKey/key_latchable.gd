extends ObstacleKey

var spear: Spear = null

@onready var grapple_collision: CollisionShape2D = $GrapplePoint/CollisionShape2D

# Check for if the player has touched the key or if a spear is attached
func _check_for_collection(body) -> void:
	if player == null and body is SWPlatformerCharacter:
		player = body
		_collect_key()
	elif spear == null and body is Spear:
		spear = body

# Alongside the normal functions, check if the spear was let go and collect key when it happens
func _physics_process(_delta):
	_move_lerp()
	if spear != null and spear.retracted:
		player = spear.player
		spear = null
		_collect_key()


# Key related functions that operate the same except also disables grapple collision

func _setup_key() -> void:
	super()
	grapple_collision.set_deferred("disabled", false)

func _reset_key() -> void:
	super()
	grapple_collision.set_deferred("disabled", false)
	spear = null

func _collect_key() -> void:
	super()
	grapple_collision.set_deferred("disabled", true)

func delete_key() -> void:
	super()
	grapple_collision.set_deferred("disabled", true)
