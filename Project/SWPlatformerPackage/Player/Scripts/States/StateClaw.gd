class_name StateClaw
extends State
@onready var player = $"../.."
const CLAW = preload("res://Objects/claw.tscn")
@export var CLAW_PULL : float = 20.0
var clawInstance
var clawVelocity : Vector2 = Vector2.ZERO
@export var clawVelDownSpeed : float = 0.55
@export var clawVelUpSpeed : float = 1.65
@export var clawVelHorizontalSpeed : float = 0.7
var clawDirection : int
var shootDirection : Vector2 = Vector2.ZERO
# This state can transition to: Idle, Move, Slide, Crouch Move
# This state happens if we are holding the Crouch key but there is no movement input.

func EnterState() -> void: 
	player.finite_state_machine.sprite_flip_lock = true
	if player.debug_mode:
		print("Debug: Claw State")
	player.animation_player.play("ShootClaw")
	clawInstance = CLAW.instantiate()
	clawInstance.global_position = player.claw_marker.global_position
	
	add_child(clawInstance)
	shootDirection = (player.get_global_mouse_position() - player.global_position).normalized()
	clawInstance.global_position += Vector2(clawDirection* 12,0)
	clawInstance.player = player
	clawInstance.Shoot(shootDirection)
	#Update sprite flip
	if sign(shootDirection.x) == 1:
		player.sprite_sheet.flip_h = false
	else:
		player.sprite_sheet.flip_h = true
	
	

func UpdatePhysics(delta) -> void: # Runs in _physics_process()
	
	# Make sure we aren't under a collision that would get us stuck in the wall 
	if clawInstance.hooked:
		#apply claw physics
		clawVelocity = player.to_local(clawInstance.tip).normalized() * CLAW_PULL
		
		if clawVelocity.y > 0:
			clawVelocity.y *= clawVelDownSpeed
		else:
			clawVelocity.y *= clawVelUpSpeed
		if shootDirection.x != 0:
			clawVelocity.x += clawVelHorizontalSpeed * shootDirection.x
	else:
		player.velocity.x = move_toward(player.velocity.x, player.run_speed * shootDirection.x, player.acceleration * delta)
		clawVelocity = Vector2.ZERO
	player.velocity += clawVelocity
		
	if clawInstance.retracted:
		player.finite_state_machine.ChangeState(player.state_idle)
	
	
func Inputs(event) -> void:
	pass

func ExitState() -> void:
	clawInstance.queue_free()
	player.finite_state_machine.sprite_flip_lock = false
