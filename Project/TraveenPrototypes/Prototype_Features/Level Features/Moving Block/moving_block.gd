class_name MovingBlock
extends Node2D

## The full name of platform movement (Enable "Editable Children" to allow animation)
@export var animation_name: String
@export_enum("Regular", "Ping Pong") var anim_loop_mode: int

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var moving_block_visual: TileMapLayer = $MovingBlockVisual

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_setup_moving_block()

# Sets up moving block, and plays it on startup
func _setup_moving_block() -> void:
	animation_player.get_animation(animation_name).set_loop_mode(set_loop_behaviour(anim_loop_mode))
	animation_player.play(animation_name)

# Returns the animation enum for the loop mode
func set_loop_behaviour(loop_mode: int, is_loopable: bool = true) -> Animation.LoopMode:
	if is_loopable:
		match (loop_mode):
			0:
				return Animation.LOOP_LINEAR
			1:
				return Animation.LOOP_PINGPONG
			_:
				return Animation.LOOP_NONE
	return Animation.LOOP_NONE
