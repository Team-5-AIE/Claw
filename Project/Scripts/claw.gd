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
var ropeLength : float = 0

func _draw():
	var offset = player.global_position - player.claw_marker.global_position
	var startPos = player.global_position-global_position - offset
	var endPos = Vector2.ZERO
	distanceToPlayer = startPos.distance_to(endPos)
	#draw_line(Vector2.ZERO, player.state_claw.endPos - player.state_claw.pivotPoint,Color.WHITE,1,false)
	draw_line(Vector2.ZERO, startPos,Color.RED,1,false)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	queue_redraw()

func _physics_process(delta):
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
	if distanceToPlayer <= 16 && hooked:
		Release()
		return
	if distanceToPlayer > maxDistance && !hooked:
		Release()
		return
	if Input.is_action_just_pressed("Jump") && !extending:
		Release()
	if Input.is_action_pressed("ClawPull"):
		ropeLength -= delta * 150
	tip = global_position

func Shoot(dir : Vector2) -> void:
	direction = dir.normalized()
	extending = true
	tip = self.global_position
	
	

func Release() -> void:
	retracted = true
	if player.is_on_floor():
		player.finite_state_machine.ChangeState(player.state_idle)
	else:
		player.finite_state_machine.ChangeState(player.state_fall)
