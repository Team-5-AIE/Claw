class_name Claw
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
var pullReleased = false
var flipped = false
var ropeSnapTimerStarted = false

func _draw():
	var clawToPlayer = player.claw_marker.global_position - global_position
	draw_line(Vector2.ZERO, clawToPlayer,Color.WHITE,1,false)
	draw_line(Vector2.ZERO, - clawToPlayer.normalized()*50, Color.DARK_ORCHID)

func _process(_delta):
	queue_redraw()
	if extending:
		claw.rotation = player.get_angle_to(tip) - deg_to_rad(-45)

func _physics_process(_delta):
	if Retract(): return
	if extending:
		var collision = move_and_collide(direction * SPEED)
		if collision:
			remove_collision_exception_with(self)
			print("A hook thing just happened!")
			ropeLength = player.claw_marker.global_position.distance_to(global_position)
			hooked = true
			extending = false
	tip = global_position
	#Auto release the hook if you're grounded
	if player.is_on_floor() && !extending && !ropeSnapTimerStarted:
		player.snap_rope_timer.start()
		ropeSnapTimerStarted = true
	if !player.is_on_floor():
		ropeSnapTimerStarted = false
	
	if player.snap_rope_timer.time_left == 0.00 && ropeSnapTimerStarted:
		Release()
		ropeSnapTimerStarted = false
		return
	
	distanceToPlayer = global_position.distance_to(player.claw_marker.global_position)
	if distanceToPlayer > maxDistance && !hooked:
		Release()
		return
	if pullReleased:
		Release()
		return
	if Input.is_action_just_pressed("Jump") && !extending:
		JumpRelease()
		return
		
	

func Shoot(dir : Vector2) -> void:
	direction = dir.normalized()
	extending = true
	tip = self.global_position

func Release() -> void:
	#print("Release")
	if player.is_on_floor():
		player.finite_state_machine.ChangeState(player.state_idle)
	else:
		player.finite_state_machine.ChangeState(player.state_fall)
	retracted = true

func JumpRelease() -> void:
	#print("Jump Release")
	if player.is_on_floor():
		player.state_fall.jumpedFromClaw = true
		player.finite_state_machine.ChangeState(player.state_idle)
	else:
		player.state_fall.jumpedFromClaw = true
		player.finite_state_machine.ChangeState(player.state_fall)
	retracted = true

func Retract() -> bool:
	if retracted:
		#print("Retract")
		var clawToPlayer = player.claw_marker.global_position - global_position
		global_position += clawToPlayer.normalized() * SPEED
		return true
	return false

func _on_auto_grapple_area_body_entered(body):
	if body.name == "Player":
		if retracted:
			queue_free()
			retracted = false
			return
	else:
		print("AutoGrapple point grabbed")
		player.state_claw.autoGrapple = true
