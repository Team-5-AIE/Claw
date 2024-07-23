extends CharacterBody2D
@onready var claw = $Claw

@onready var direction : Vector2
@onready var speed : float = 5
var player : CharacterBody2D
var tip : Vector2 = Vector2(0,0)

@export var SPEED : float = 20
@export var maxDistance = 150
var extending : bool = false
var hooked : bool = false
var retracted : bool = false
var distanceToPlayer : float = 0

func _draw():
	var offset = player.global_position - player.claw_marker.global_position
	var startPos = player.global_position-global_position - offset
	var endPos = Vector2.ZERO
	distanceToPlayer = startPos.distance_to(endPos)
	draw_line(startPos, endPos,Color.WHITE,1,false)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	queue_redraw()

func _physics_process(delta):
	if extending :
		if move_and_collide(direction * SPEED):
			hooked = true
			extending = false
	if distanceToPlayer > maxDistance:
		Release()
		return
	if distanceToPlayer <= 16 && hooked:
		Release()
		return
		
	if Input.is_action_just_released("Claw") && !extending:
		Release()
	tip = global_position

func Shoot(dir : Vector2) -> void:
	direction = dir.normalized()
	extending = true
	tip = self.global_position
	

func Release() -> void:
	retracted = true
