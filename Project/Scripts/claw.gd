class_name Claw
extends CharacterBody2D
@onready var claw_right = $ClawRight
@onready var claw_left = $ClawLeft

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
var ropeLength : float = 0
var released = false
var flipped = false
func _ready() -> void:
	if flipped:
		claw_left.visible = true
		claw_right.visible = false
	else:
		claw_right.visible = true
		claw_left.visible = false

func _draw():
	var offset = player.global_position - player.claw_marker.global_position
	var startPos = player.global_position-global_position - offset
	var endPos = Vector2.ZERO
	distanceToPlayer = startPos.distance_to(endPos)
	#draw_line(Vector2.ZERO, player.state_claw.endPos - player.state_claw.pivotPoint,Color.WHITE,1,false)
	draw_line(Vector2.ZERO, startPos,Color.WHITE,1,false)
	var clawToPlayer = player.claw_marker.global_position - global_position
	draw_line(Vector2.ZERO, - clawToPlayer.normalized()*50, Color.DARK_ORCHID)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	queue_redraw()

func _physics_process(_delta):
	if extending:
		if move_and_collide(direction * SPEED):
			#var offset = player.global_position - player.claw_marker.global_position
			#var startPos = player.global_position-global_position - offset
			#var endPos = Vector2.ZERO
			#startPos.distance_to(endPos)
			print("A hook thing just happened!")
			ropeLength = player.claw_marker.global_position.distance_to(global_position)
			player.state_claw.SetStartPosition(global_position,player.claw_marker.global_position)
			hooked = true
			extending = false
	#NOTE: UNCOMMENT
	if distanceToPlayer > maxDistance && !hooked:
		released = true
	if Input.is_action_just_pressed("Jump") && !extending:
		released = true
	if released:
		Release()
	tip = global_position

func Shoot(dir : Vector2) -> void:
	direction = dir.normalized()
	extending = true
	tip = self.global_position
	
	

func Release() -> void:
	print("release")
	var clawToPlayer = player.claw_marker.global_position - global_position
	global_position += clawToPlayer.normalized() * SPEED
	if player.is_on_floor():
		player.finite_state_machine.ChangeState(player.state_idle)
	else:
		player.finite_state_machine.ChangeState(player.state_fall)
	retracted = true
