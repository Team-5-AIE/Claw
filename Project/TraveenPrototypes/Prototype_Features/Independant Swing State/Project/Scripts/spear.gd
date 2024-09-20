#class_name Spear
extends CharacterBody2D
@onready var spear: Sprite2D = $Spear


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

# Moving Block Addition
var attachedObject : Node2D

# No jump sounds since swing now directly links to jump state

func _draw():
	var spearToPlayer = player.spear_marker.global_position - global_position
	draw_line(Vector2.ZERO, spearToPlayer,Color.WHITE,1,false)

func _process(_delta):
	queue_redraw()
	if extending:
		spear.rotation = player.get_angle_to(tip) - deg_to_rad(-45)

func _physics_process(_delta):
	if Retract(): return
	if extending:
		var collision = move_and_collide(direction * SPEED)
		if collision:
			remove_collision_exception_with(self)
			print("A hook thing just happened!")
			ropeLength = player.spear_marker.global_position.distance_to(global_position)
			hooked = true
			extending = false
			attachedObject = collision.get_collider()
			player.finite_state_machine.EnableSwing() # Replaced changeState
	tip = global_position
	
	# Moving block Addition
	if attachedObject != null && attachedObject is MovingBlock:
		self.position += attachedObject.constant_linear_velocity * _delta
	
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
	
	distanceToPlayer = global_position.distance_to(player.spear_marker.global_position)
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
	player.finite_state_machine.DisableSwing() # Simplified from having to detect if player is on floor
	retracted = true
	
	# Moving Block addition
	attachedObject = null

func JumpRelease() -> void:
	# No jump sounds since swing now directly links to jump state
	if player.is_on_floor():
		player.state_fall.jumpedFromSpear = true
	else:
		player.state_fall.jumpedFromSpear = false
	player.finite_state_machine.ChangeState(player.state_jump)
	player.finite_state_machine.DisableSwing()
	retracted = true

func Retract() -> bool:
	if retracted:
		var spearToPlayer = player.spear_marker.global_position - global_position
		global_position += spearToPlayer.normalized() * SPEED
		return true
	return false

func _on_auto_grapple_area_body_entered(body):
	if body.name == "Player":
		if retracted:
			extending = false
			retracted = false
			queue_free()
			return
	else:
		print("AutoGrapple point grabbed")
		player.state_spear.autoGrapple = true
