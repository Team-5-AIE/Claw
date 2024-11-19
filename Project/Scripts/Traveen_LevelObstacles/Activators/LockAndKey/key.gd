class_name ObstacleKey
extends Node2D

signal key_collected(id: int)
signal key_reset(id: int)

var keyID : int = 0
var follow : bool = false
var player = null
var collected = false
var targetPosition = Vector2.ZERO
var initialPosition
var initialGlobalPosition

@onready var lockParent = get_parent()
@onready var keyImpression = $Hole
@onready var light = $Sprite2D/PointLight2D
@onready var collection_timer = $CollectionTimer
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	initialPosition = position
	_setup_key()

func _physics_process(_delta):
	_move_lerp()


# Follow behind player, trailing amount depending on keyID
func _move_lerp() -> void:
	if player != null and follow:
		targetPosition = player.bloomieMarker2D.global_position
		global_position.x = lerp(global_position.x, targetPosition.x, 0.1 * (keyID + 1))
		global_position.y = lerp(global_position.y, targetPosition.y, 0.1 * (keyID + 1))
	else:
		position.x = lerp(position.x, initialPosition.x, 0.1 * (keyID + 1))
		position.y = lerp(position.y, initialPosition.y, 0.1 * (keyID + 1))

# Reset the keys when player dies
func _on_restart_player() -> void:
	if player != null:
		follow = false
		collected = false
		collection_timer.stop()
		await FadeTransitions.on_fade_in_finished
		top_level = false
		if lockParent == null:
			delete_key()
		else:
			_reset_key()
		player = null

# Play collection animation, wait for the sound to end, then delete key
func _on_collection_timer_timeout():
	collected = true
	AudioManager.play_game_sound(AudioManager.COLLECT_BLOOMIE) # Replace with key collect sound
	animation_player.play("Fade")
	await animation_player.animation_finished
	delete_key()

func _on_area_2d_body_entered(body) -> void:
	if not follow:
		_check_for_collection(body)

func on_lock_activated(_switchID: int) -> void:
	collection_timer.start(collection_timer.wait_time * (float(keyID)+1))


# Set up the key with all its initial values and states
func _setup_key() -> void:
	initialPosition = position
	initialGlobalPosition = global_position
	lockParent.activated.connect(on_lock_activated)
	keyImpression.visible = false
	light.visible = true
	animation_player.play("Float")

# Check for if the player has touched the key for it to be collected
func _check_for_collection(body) -> void:
	if player == null and body is SWPlatformerCharacter:
		player = body
		_collect_key()

# Let player collect the key and make it follow them. Also leave behind a key impression.
func _collect_key() -> void:
	initialGlobalPosition = global_position
	
	top_level = true
	light.visible = true
	# Move hole to door parent
	keyImpression.visible = true
	keyImpression.reparent(lockParent)
	keyImpression.call_deferred("set_global_position", initialGlobalPosition)
	
	reparent(player)
	call_deferred("set_global_position", initialGlobalPosition)
	
	player.restartPlayer.connect(_on_restart_player)
	key_collected.emit(keyID)
	
	follow = true
	print("pick up key")

# Reset key and its impression back to its original state
func _reset_key() -> void:
	keyImpression.reparent(self)
	keyImpression.visible = false
	light.visible = true
	
	reparent(lockParent)
	position = initialPosition
	
	animation_player.play("Float")
	key_reset.emit(keyID)

# Delete the key. Also reparent the impression if it hasn't already been.
func delete_key() -> void:
	light.visible = false
	
	if not keyImpression.visible or not follow:
		initialGlobalPosition = global_position
		# Move hole to door parent
		keyImpression.visible = true
		keyImpression.reparent(lockParent)
		keyImpression.global_position = initialGlobalPosition
	
	reparent(lockParent)
	position = initialPosition
	
	collected = false
	queue_free()
