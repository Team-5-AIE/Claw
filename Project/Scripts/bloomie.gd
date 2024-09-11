extends Node2D

var follow : bool = false
var player = null
var collected = false
@onready var destroy_timer = $DestroyTimer
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
const COLLECT_BLOOMIE = preload("res://Sounds/Effects/collectBloomie.wav")
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@export var bloomieID : int = 0
var targetPosition = Vector2.ZERO
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	animation_player.play("Float")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta)-> void:
	if player != null:
		targetPosition = player.bloomieMarker2D.global_position
		global_position.x = lerp(global_position.x, targetPosition.x, 0.1)
		global_position.y = lerp(global_position.y, targetPosition.y, 0.1)
	if follow:
		if player.is_on_floor():
			collected = true
			follow = false
			destroy_timer.start()
			audio_stream_player.stream = COLLECT_BLOOMIE
			audio_stream_player.play()
			animation_player.play("Fade")
	if collected:
		if destroy_timer.time_left <= 0.0:
			if !audio_stream_player.playing:
				#Add bloomie to display
				var bloomieDisplay = get_tree().root.get_node("/root/GameRoot2/CanvasLayer/BloomieDisplay")
				bloomieDisplay.AddBloomieCount(bloomieID)
				queue_free()


func _on_area_2d_body_entered(body) -> void:
	if body.name == "Player":
		player = body
		follow = true
		print("pick up bloomie")
