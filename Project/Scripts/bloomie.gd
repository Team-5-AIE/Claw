extends Node2D

var follow : bool = false
var player = null
var collected = false
@onready var destroy_timer = $DestroyTimer

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
	if collected:
		if destroy_timer.time_left > 0.0:
			global_position.y -= 1
		else:
			queue_free()


func _on_area_2d_body_entered(body) -> void:
	if body.name == "Player":
		player = body
		follow = true
		print("pick up bloomie")
