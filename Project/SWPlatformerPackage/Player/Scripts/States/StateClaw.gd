class_name StateClaw
extends State
@onready var player = $"../.."
const CLAW = preload("res://Objects/claw.tscn")
@export var CLAW_PULL : float = 20.0
var clawInstance
@export var clawVelSpeed : float = 0.7
var shootDirection : Vector2 = Vector2.ZERO
@export var swingSpeed : float = 50
@export var pullJumpStrength : float = 350
@export var pullJumpStopFraction : float = 1
#Physics pendulum stuff
var pivotPoint : Vector2 = Vector2.ZERO #point the pengulum rotates around
var endPos : Vector2 #global_position
var length : float # get the angle between position + godot angle offset
var gravity =  0.4 * 60
var angle
var damping = 0.995
var angularVel : float = 0.0
var angularAcceleration : float = 0.0
var correctionNeeded = true
var autoGrapple : bool = false
#=================================================================================
func EnterState() -> void:
	if clawInstance != null:
		print("Claw already exists while we entered claw state - not retracted")
	autoGrapple = false
	#player.finite_state_machine.disable_gravity = true
	correctionNeeded = true
	if player.debug_mode:
		print("Debug: Claw State")
	
	player.animation_player.play("Idle") #TODO: Look less jank - calulate movement and animations
	# Get direction to shoot in
	if player.lockclaw45direction || Input.is_action_just_pressed("C"):
		shootDirection = Vector2(player.last_input_direction.x,-1)
	else:
		shootDirection = (player.get_global_mouse_position() - player.claw_marker.global_position)
	# Update sprite flip to the shoot direction
	player.finite_state_machine.sprite_flip_lock = true
	clawInstance = CLAW.instantiate()
	if sign(shootDirection.x) == 1:
		player.claw_marker.global_position = player.global_position + Vector2(-6,-28)
		player.sprite_sheet.flip_h = false
		clawInstance.flipped = false
	else:
		player.claw_marker.global_position = player.global_position + Vector2(6,-28)
		player.sprite_sheet.flip_h = true
		clawInstance.flipped = true

	#Create claw and set it up
	
	
	add_child(clawInstance)
	clawInstance.player = player
	clawInstance.global_position = player.claw_marker.global_position
	clawInstance.Shoot(shootDirection)
#=================================================================================
func UpdatePhysics(delta) -> void: # Runs in _physics_process()
	if clawInstance.hooked:
		player.animation_player.play("ShootClaw")
		ProcessVelocity(delta)
	else:
		# We haven't hooked the claw - free movement
		if player.is_on_floor():
			player.velocity.x = move_toward(player.velocity.x, player.run_speed * player.input_axis.x, player.acceleration * delta)

func Inputs(_event) -> void:
	if Input.is_action_just_pressed("Down"):
		clawInstance.retracted = true
		player.finite_state_machine.ChangeState(player.state_fall)

func ExitState() -> void:
	clawInstance = null
	player.finite_state_machine.sprite_flip_lock = false
	pivotPoint = Vector2.ZERO
	#player.finite_state_machine.disable_gravity = false
	player.spearCooldownTimer.start()
#=================================================================================
func ProcessVelocity(delta:float) -> void:
	var clawToPlayer = player.claw_marker.global_position - clawInstance.global_position
	var ropeDirection : Vector2 = clawToPlayer
	
	#AutoGrapple
	if Input.is_action_just_pressed("ClawPull") || autoGrapple:
		clawInstance.pullReleased = true
		#if clawInstance.ropeLength > 16:
		#	clawInstance.ropeLength -= delta * 150
		player.velocity *= (1.0 - pullJumpStopFraction)
		player.velocity += -clawToPlayer.normalized() * pullJumpStrength
		
	var currentRopeLength : float = ropeDirection.length()
	ropeDirection /= currentRopeLength
	
	var circularArcDirection : Vector2 = Vector2(ropeDirection.y, -ropeDirection.x)
	var trueRopeLength : float = clawInstance.ropeLength
	
	if currentRopeLength > trueRopeLength:
		var overextendedAmount : float = currentRopeLength - trueRopeLength
		var correctiveMovement : Vector2 = -overextendedAmount * ropeDirection
		var cachedVel = player.velocity
		
		player.velocity = correctiveMovement / delta
		player.move_and_slide()
		player.velocity = cachedVel;
		
		#fix velocity
		if ropeDirection.dot(player.velocity) > 0:
			player.velocity = player.velocity.dot(circularArcDirection) * circularArcDirection
		
		#player.velocity = vel
	if player.input_axis.x != 0:
		player.velocity += circularArcDirection * player.input_axis.x * 8
#=================================================================================
func AddAngularVelocity(force:float)-> void:
	angularVel += force
