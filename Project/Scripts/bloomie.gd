extends Node2D

var follow : bool = false
var player = null
var collected = false
@onready var destroy_timer = $DestroyTimer
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
const COLLECT_BLOOMIE = preload("res://Sounds/Effects/collectBloomie.wav")
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta)-> void:
	if follow:
		global_position = player.bloomieMarker2D.global_position
		if player.is_on_floor():
			collected = true
			follow = false
			destroy_timer.start()
			audio_stream_player.stream = COLLECT_BLOOMIE
			audio_stream_player.play()
	if collected:
		if destroy_timer.time_left > 0.0:
			global_position.y -= 1
		else:
			animated_sprite_2d.modulate.a -= 5
			if !audio_stream_player.playing:
				queue_free()


func _on_area_2d_body_entered(body) -> void:
	if body.name == "Player":
		player = body
		follow = true
		print("pick up bloomie")
