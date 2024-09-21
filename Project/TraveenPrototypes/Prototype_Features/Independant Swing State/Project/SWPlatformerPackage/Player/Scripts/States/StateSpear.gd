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
var angularVel : float = 0.0
var angularAcceleration : float = 0.0
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
	ProcessVelocity(delta)

func Inputs(_event) -> void:
	if Input.is_action_just_pressed("LetGoOfSpear"):
		if spearInstance != null:
			spearInstance.retracted = true
		player.finite_state_machine.DisableSwing() # Replaced state change with disabling swing

func ExitState() -> void:
	# Attached Object addition
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
func ProcessVelocity(delta:float) -> void:
	if spearInstance == null: return
	var spearToPlayer = player.spear_marker.global_position - spearInstance.global_position
	var ropeDirection : Vector2 = spearToPlayer
	
	#AutoGrapple
	if Input.is_action_just_pressed("SpearPull"):
		audio_stream_player.stream = PULLJUMP
		audio_stream_player.play()
		spearInstance.pullReleased = true
		player.velocity *= (1.0 - pullJumpStopFraction)
		player.velocity += -spearToPlayer.normalized() * pullJumpStrength
		
	if autoGrapple:
		audio_stream_player.stream = PULLJUMP
		audio_stream_player.play()
		spearInstance.pullReleased = true
		player.velocity *= (1.0 - pullJumpStopFraction)
		player.velocity += -spearToPlayer.normalized() * pullJumpStrength
		
		
	var currentRopeLength : float = ropeDirection.length()
	ropeDirection /= currentRopeLength
	
	var circularArcDirection : Vector2 = Vector2(ropeDirection.y, -ropeDirection.x)
	var trueRopeLength : float = spearInstance.ropeLength
	
	if currentRopeLength >= trueRopeLength:
		var overextendedAmount : float = currentRopeLength - trueRopeLength
		var correctiveMovement : Vector2 = -overextendedAmount * ropeDirection
		var cachedVel = player.velocity
		
		
		# The swinging now only plays as a correction, therefore making it scale with other states' forces
		player.velocity = correctiveMovement / delta
		player.move_and_slide()
		player.velocity = cachedVel;
		
		if ropeDirection.dot(player.velocity) > 0:
			player.velocity = player.velocity.dot(circularArcDirection) * circularArcDirection
		
		player.velocity += circularArcDirection * player.input_axis.x * 4
		player.animation_player.play("ShootSpear")
		
	elif autoShortenRope: # A Remnants of Naezith mechanic, might be cool or might not care
		spearInstance.ropeLength = currentRopeLength
#=================================================================================
func AddAngularVelocity(force:float)-> void:
	angularVel += force
