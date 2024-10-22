extends Node2D

var follow : bool = false
var player = null
var collecting = false
var collected = false
@onready var destroy_timer = $DestroyTimer
@onready var collection_timer = $CollectionTimer
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
const COLLECT_BLOOMIE = preload("res://Sounds/Effects/collectBloomie.wav")
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@export var bloomieID : int = 0
@onready var initialParent = get_parent()
@onready var initialPosition = position
var targetPosition = Vector2.ZERO
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Global.chapterOneBloomiesThisSession[bloomieID] == true:
		queue_free()
	
	animation_player.play("Float")

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
		global_position.x = lerp(global_position.x, targetPosition.x, 0.1)
		global_position.y = lerp(global_position.y, targetPosition.y, 0.1)
	else:
		position.x = lerp(position.x, initialPosition.x, 0.1)
		position.y = lerp(position.y, initialPosition.y, 0.1)
	
	if collected:
		if !audio_stream_player.playing:
			#Add bloomie to display
			var bloomieDisplay = get_tree().root.get_node("/root/GameRoot2/CanvasLayer/BloomieDisplay")
			bloomieDisplay.AddBloomieCount(bloomieID)
			Global.chapterOneBloomies[bloomieID] = true
			Global.chapterOneBloomiesThisSession[bloomieID] = true
			queue_free()

func _on_collection_timer_timeout():
	collecting = true
	destroy_timer.start()
	audio_stream_player.stream = COLLECT_BLOOMIE
	audio_stream_player.play()
	animation_player.play("Fade")

func _on_destroy_timer_timeout():
	collected = true

func _on_restart_player() -> void:
	if player != null:
		follow = false
		
		collection_timer.stop()
			
		await FadeTransitions.on_fade_in_finished
		top_level = false
		player.remove_child(self)
		
		if initialParent == null:
			queue_free()
		else:
			initialParent.add_child(self)
			position = initialPosition
			
			player = null

func _on_area_2d_body_entered(body) -> void:
	if player == null and body.name == "Player":
		player = body
		
		# The bloomie needs to be a child of the player so that it stays loaded
		# when its room unloads, but we don't want it to move with the player
		# directly.
		# To achieve both things, we can turn on top_level to have the bloomie
		# behave as if it were a child of root instead
		var initialGlobalPosition = global_position
		top_level = true
		initialParent.call_deferred("remove_child", self)
		player.call_deferred("add_child", self)
		position = initialGlobalPosition
		
		player.restartPlayer.connect(_on_restart_player)
		
		follow = true
		print("pick up bloomie")
