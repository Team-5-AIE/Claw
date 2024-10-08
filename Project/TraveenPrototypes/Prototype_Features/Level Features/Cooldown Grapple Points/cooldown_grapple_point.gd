class_name CooldownGrapplePoint
extends Node2D

@export var cooldown: float = 2.5

@onready var active_collision: CollisionShape2D = $CollisionShape2D
@onready var active_sprite: Sprite2D = $ActiveSprite
@onready var inactive_sprite: Sprite2D = $InactiveSprite
@onready var cooldown_timer: Timer = $GrapplePointCooldown

func _ready() -> void:
	cooldown_timer.wait_time = cooldown

func start_cooldown() -> void:
	active_collision.set_deferred("disabled", true)
	active_sprite.visible = false
	inactive_sprite.visible = true
	cooldown_timer.start()

func _on_grapple_point_cooldown_timeout() -> void:
	active_collision.set_deferred("disabled", false)
	active_sprite.visible = true
	inactive_sprite.visible = false
