class_name MovingBlock
extends Node2D

## The full name of platform movement (Enable "Editable Children" to allow animation)
@export var animation_name: String

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var moving_block_visual: TileMapLayer = $MovingBlockVisual

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_setup_moving_block()

# Sets up moving block, and plays it on startup
func _setup_moving_block() -> void:
	animation_player.get_animation(animation_name).set_loop_mode(Animation.LOOP_LINEAR)
	animation_player.play(animation_name)
