class_name ObstacleKey
extends Node2D

signal key_collected(id: int)

var follow : bool = false
var player = null
var collecting = false
var collected = false
@onready var destroy_timer = $DestroyTimer
@onready var collection_timer = $CollectionTimer
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var initialPosition = position
var targetPosition = Vector2.ZERO

@export var keyID : int = 0
@onready var doorParent = get_parent()
@onready var keyImpression = $Hole
const COLLECT_KEY = preload("res://Sounds/Effects/collectBloomie.wav")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	keyImpression.visible = false
	animation_player.play("Float")

func delete_key(delete: bool) -> void:
	var initialGlobalPosition = global_position
	# Move hole to door parent
	keyImpression.visible = true
	remove_child(keyImpression)
	doorParent.add_child(keyImpression)
	keyImpression.global_position = initialGlobalPosition
	key_collected.emit(keyID)
	queue_free()

func _physics_process(_delta):
	if follow and !collecting:
		if player.is_on_floor():
			if collection_timer.is_stopped():
				collection_timer.start()
		elif collection_timer.time_left > 0.0:
			collection_timer.stop()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta)-> void:
	if player != null:
		targetPosition = player.bloomieMarker2D.global_position
		global_position.x = lerp(global_position.x, targetPosition.x, 0.1 * (keyID + 1))
		global_position.y = lerp(global_position.y, targetPosition.y, 0.1 * (keyID + 1))
	else:
		position.x = lerp(position.x, initialPosition.x, 0.1 * (keyID + 1))
		position.y = lerp(position.y, initialPosition.y, 0.1 * (keyID + 1))
	
	if collected:
		if !audio_stream_player.playing:
			key_collected.emit(keyID)
			queue_free()

func _on_collection_timer_timeout():
	collecting = true
	destroy_timer.start()
	audio_stream_player.stream = COLLECT_KEY
	audio_stream_player.play()
	animation_player.play("Fade")

func _on_destroy_timer_timeout():
	collected = true

func _on_restart_player() -> void:
	var initialGlobalPosition = global_position
	if player != null:
		follow = false
		
		collection_timer.stop()
			
		await FadeTransitions.on_fade_in_finished
		top_level = false
		player.remove_child(self)
		
		if doorParent == null:
			key_collected.emit(keyID)
			queue_free()
		else:
			doorParent.add_child(self)
			global_position = initialGlobalPosition
			doorParent.keys.append
			
			doorParent.remove_child(keyImpression)
			add_child(keyImpression)
			keyImpression.global_position = initialGlobalPosition
			keyImpression.visible = false
			
			player = null

func _on_area_2d_body_entered(body) -> void:
	var initialGlobalPosition = global_position
	if player == null and body.name == "Player":
		player = body
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
		
