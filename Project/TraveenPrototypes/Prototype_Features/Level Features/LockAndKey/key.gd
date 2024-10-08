class_name ObstacleKey
extends Node2D

signal key_collected(id: int)
signal key_reset(id: int)

const COLLECT_KEY = preload("res://Sounds/Effects/collectBloomie.wav")

@export var keyID : int = 0

var follow : bool = false
var player = null
var collecting = false
var collected = false
var targetPosition = Vector2.ZERO
var initialPosition
var initialGlobalPosition

@onready var lockParent = get_parent()
@onready var keyImpression = $Hole
@onready var light = $PointLight2D
@onready var destroy_timer = $DestroyTimer
@onready var collection_timer = $CollectionTimer
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var animation_player: AnimationPlayer = $AnimationPlayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_setup_key()

func _physics_process(_delta):
	if collected:
		if !audio_stream_player.playing:
			delete_key()
	
	if follow and !collecting:
		if player.is_on_floor():
			if collection_timer.is_stopped():
				collection_timer.start()
		elif collection_timer.time_left > 0.0:
			collection_timer.stop()
	
	_move_lerp()

func _move_lerp() -> void:
	await get_tree().physics_frame
	if player != null:
		targetPosition = player.bloomieMarker2D.global_position
		global_position.x = lerp(global_position.x, targetPosition.x, 0.1 * (keyID + 1))
		global_position.y = lerp(global_position.y, targetPosition.y, 0.1 * (keyID + 1))
	else:
		position.x = lerp(position.x, initialPosition.x, 0.1 * (keyID + 1))
		position.y = lerp(position.y, initialPosition.y, 0.1 * (keyID + 1))

func _on_collection_timer_timeout():
	collecting = true
	destroy_timer.start()
	audio_stream_player.stream = COLLECT_KEY
	audio_stream_player.play()
	animation_player.play("Fade")

func _on_destroy_timer_timeout():
	collected = true

func _on_restart_player() -> void:
	if player != null:
		follow = false
		collecting = false
		collected = false
		
		collection_timer.stop()
			
		await FadeTransitions.on_fade_in_finished
		top_level = false
		
		if lockParent == null:
			delete_key()
		else:
			_reset_key()
			
			player = null

func _on_area_2d_body_entered(body) -> void:
	if player == null and body.name == "Player":
		player = body
		_collect_key()

func _setup_key() -> void:
	initialPosition = position
	initialGlobalPosition = global_position
	lockParent.unlocked.connect(on_unlocked)
	keyImpression.visible = false
	light.visible = true
	animation_player.play("Float")

func _reset_key() -> void:
	keyImpression.reparent(self)
	keyImpression.visible = false
	light.visible = true
	
	reparent(lockParent)
	position = initialPosition
	
	animation_player.play("Float")
	key_reset.emit(keyID)

func _collect_key() -> void:
	top_level = true
	light.visible = true
	# Move hole to door parent
	keyImpression.visible = true
	keyImpression.reparent(lockParent)
	
	reparent(player)
	global_position = player.bloomieMarker2D.global_position
	
	player.restartPlayer.connect(_on_restart_player)
	
	follow = true
	print("pick up key")

func delete_key() -> void:
	light.visible = false
	
	if not keyImpression.visible:
		# Move hole to door parent
		keyImpression.visible = true
		keyImpression.reparent(lockParent)
	
	reparent(lockParent)
	position = initialPosition
	
	collected = false
	key_collected.emit(keyID)

func on_unlocked() -> void:
	queue_free()
