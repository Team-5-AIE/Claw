class_name StateSpear
extends State
@onready var player = $"../.."
const SPEAR = preload("res://Objects/spear.tscn")
@export var SPEAR_PULL : float = 20.0
var spearInstance
@export var spearVelSpeed : float = 0.7
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
var autoGrapple : bool = false
var hookSoundPlayed = false
@onready var audio_stream_player: AudioStreamPlayer = $"../../AudioStreamPlayer"
const HOOK1 = preload("res://Sounds/Effects/click (1).wav")
const HOOK2 = preload("res://Sounds/Effects/click.wav")
const PULLJUMP = preload("res://Sounds/Effects/pullJump.wav")
#=================================================================================
func EnterState() -> void:
	hookSoundPlayed = false
	autoGrapple = false
	if player.debug_mode:
		print("Debug: Spear State")
	# Update sprite flip to the shoot direction
	player.finite_state_machine.sprite_flip_lock = true
	player.animation_player.play("ShootSpear")
	
	
#=================================================================================
func UpdatePhysics(delta) -> void: # Runs in _physics_process()
	if !hookSoundPlayed:
		var randSound = randi_range(0,1)
		match randSound:
			0: audio_stream_player.stream = HOOK1
			1: audio_stream_player.stream = HOOK2
		audio_stream_player.play()
		hookSoundPlayed = true
	
	ProcessVelocity(delta)

func Inputs(_event) -> void:
	if Input.is_action_just_pressed("LetGoOfSpear"):
		spearInstance.retracted = true
		player.finite_state_machine.ChangeState(player.state_fall)

func ExitState() -> void:
	spearInstance = null
	player.finite_state_machine.sprite_flip_lock = false
	pivotPoint = Vector2.ZERO
	#player.finite_state_machine.disable_gravity = false
	player.spearCooldownTimer.start()
#=================================================================================
func ProcessVelocity(delta:float) -> void:
	var spearToPlayer = player.spear_marker.global_position - spearInstance.global_position
	var ropeDirection : Vector2 = spearToPlayer
	
	#AutoGrapple
	if Input.is_action_just_pressed("SpearPull"):
		audio_stream_player.stream = PULLJUMP
		audio_stream_player.play()
		spearInstance.pullReleased = true
		#if spearInstance.ropeLength > 16:
		#	spearInstance.ropeLength -= delta * 150
		player.velocity *= (1.0 - pullJumpStopFraction)
		player.velocity += -spearToPlayer.normalized() * pullJumpStrength
		
	if autoGrapple:
		audio_stream_player.stream = PULLJUMP #TODO: change this 
		audio_stream_player.play()
		spearInstance.pullReleased = true
		#if spearInstance.ropeLength > 16:
		#	spearInstance.ropeLength -= delta * 150
		player.velocity *= (1.0 - pullJumpStopFraction)
		player.velocity += -spearToPlayer.normalized() * pullJumpStrength
		
		
	var currentRopeLength : float = ropeDirection.length()
	ropeDirection /= currentRopeLength
	
	var circularArcDirection : Vector2 = Vector2(ropeDirection.y, -ropeDirection.x)
	var trueRopeLength : float = spearInstance.ropeLength
	
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