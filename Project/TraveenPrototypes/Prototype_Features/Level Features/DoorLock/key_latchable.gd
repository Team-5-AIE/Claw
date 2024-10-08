extends ObstacleKey

@onready var grapple_collision: CollisionShape2D = $GrapplePoint/CollisionShape2D

func _ready() -> void:
	keyImpression.visible = false
	grapple_collision.disabled = false
	animation_player.play("Float")

func _reset_key() -> void:
	var initialGlobalPosition = global_position
	grapple_collision.disabled = false
	global_position = initialGlobalPosition
	
	doorParent.remove_child(keyImpression)
	add_child(keyImpression)
	keyImpression.global_position = initialGlobalPosition
	keyImpression.visible = false

func _collect_key() -> void:
	var initialGlobalPosition = global_position
	grapple_collision.disabled = true
	top_level = true
	
	# Move hole to door parent
	keyImpression.visible = true
	remove_child(keyImpression)
	doorParent.add_child(keyImpression)
	keyImpression.global_position = initialGlobalPosition
	
	doorParent.remove_child(self)
	player.add_child(self)
	global_position = initialGlobalPosition
	
	player.restartPlayer.connect(_on_restart_player)
	
	follow = true
	print("pick up key")
	

func delete_key() -> void:
	grapple_collision.disabled = true
	if not keyImpression.visible:
		var initialGlobalPosition = global_position
		# Move hole to door parent
		keyImpression.visible = true
		remove_child(keyImpression)
		doorParent.add_child(keyImpression)
		keyImpression.global_position = initialGlobalPosition
	
	key_collected.emit(keyID)
	queue_free()
