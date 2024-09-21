#class_name StateSpear
extends State
@onready var player = $"../.."
const SPEAR = preload("res://Objects/spear.tscn")
@export var SPEAR_PULL : float = 20.0
var spearInstance
@export var spearVelSpeed : float = 0.7
var shootDirection : Vector2 = Vector2.ZERO
@export var swingSpeed : float = 50
@export var autoShortenRope : bool = false
@export var pullJumpStrength : float = 350
@export var pullJumpStopFraction : float = 1
#Physics pendulum stuff
var pivotPoint : Vector2 = Vector2.ZERO #point the pengulum rotates around
var endPos : Vector2 #global_position
var length : float # get the angle between position + godot angle offset
var gravity =  0.4 * 60
var angle
var damping = 0.995
var angularVelocity : Vector2
var angularAcceleration : Vector2
var autoGrapple : bool = false
@onready var audio_stream_player: AudioStreamPlayer = $"../../AudioStreamPlayer"
const HOOK1 = preload("res://Sounds/Effects/click (1).wav")
const HOOK2 = preload("res://Sounds/Effects/click.wav")
const PULLJUMP = preload("res://Sounds/Effects/pullJump.wav")
#=================================================================================
func EnterState() -> void:
	if player.debug_mode:
		print("Debug: Spear State")
	var randSound = randi_range(0,1)
	match randSound:
		0: audio_stream_player.stream = HOOK1
		1: audio_stream_player.stream = HOOK2
	audio_stream_player.play()


#=================================================================================
func UpdatePhysics(delta) -> void: # Runs in _physics_process()
	if spearInstance == null: return
	var spearToPlayer = player.spear_marker.global_position - spearInstance.global_position
	
	#AutoGrapple
	if Input.is_action_just_pressed("SpearPull"):
		audio_stream_player.stream = PULLJUMP
		audio_stream_player.play()
		spearInstance.pullReleased = true
		player.velocity *= (1.0 - pullJumpStopFraction)
		player.velocity += -spearToPlayer.normalized() * pullJumpStrength
		return
		
	if autoGrapple:
		audio_stream_player.stream = PULLJUMP
		audio_stream_player.play()
		spearInstance.pullReleased = true
		player.velocity *= (1.0 - pullJumpStopFraction)
		player.velocity += -spearToPlayer.normalized() * pullJumpStrength
		return
	
	ProcessVelocity(delta, spearToPlayer)

func Inputs(_event) -> void:
	if Input.is_action_just_pressed("LetGoOfSpear"):
		if spearInstance != null:
			spearInstance.retracted = true
		player.finite_state_machine.DisableSwing() # Replaced state change with disabling swing

func ExitState() -> void:
	# Attached Object addition
	if spearInstance != null:
		if spearInstance.attachedObject != null:
			if spearInstance.attachedObject is LimitedGrapplePoint: 
				spearInstance.attachedObject.start_cooldown()
			spearInstance.attachedObject = null
		spearInstance = null
	
	pivotPoint = Vector2.ZERO
	player.spearCooldownTimer.start()
	
	if player.finite_state_machine.state == player.state_fall:
		var dust_instance = player.instance_create(player.RUN_DUST_PARTICLES,player)
		dust_instance.scale.x = sign(-player.velocity.x)
		dust_instance.set_as_top_level(true)
		dust_instance.global_position = player.dustMarker2D.global_position
#=================================================================================
func ProcessVelocity(delta:float, spearToPlayer:Vector2) -> void:
	if spearInstance == null: return
	
	var ropeDirection : Vector2 = spearToPlayer
	var currentRopeLength : float = spearToPlayer.length()
	ropeDirection /= currentRopeLength
	var trueRopeLength : float = spearInstance.ropeLength
	
	var circularArcDirection : Vector2 = Vector2(ropeDirection.y, -ropeDirection.x)
	angle = circularArcDirection.angle()
	
	if currentRopeLength > trueRopeLength:
		player.animation_player.play("ShootSpear")
		
		player.velocity = circularArcDirection.dot(player.velocity) * circularArcDirection
		
		var next_velocity = player.finite_state_machine.previous_vel - player.velocity
		var circular_input_vel = circularArcDirection * player.input_axis.x * player.air_acceleration * delta
		angularVelocity = (next_velocity + circular_input_vel) / trueRopeLength * sin(angle)
		player.velocity += circularArcDirection.dot(angularVelocity) * circularArcDirection
		
		var correctiveMovement : Vector2 = -(currentRopeLength - trueRopeLength) * ropeDirection
		player.velocity += correctiveMovement / delta
	
	player.move_and_slide()
	
	if autoShortenRope and currentRopeLength < trueRopeLength: # A Remnants of Naezith mechanic, might be cool or might not care
		spearInstance.ropeLength = currentRopeLength
