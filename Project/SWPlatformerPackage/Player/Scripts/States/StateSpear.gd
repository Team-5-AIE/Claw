
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
var hookSoundPlayed = false
var angularVelocity : Vector2
var inputAmount : float = 0
var drawVisual : bool = true

@export var swingSpeedDecreaseModifier = 0.2
@export var swingSpeedIncreaseModifier = 0.5
@export var swingSpeedCap = 10

@export_group("Rope Climbing")
@export var climbRopeSpeedUp : int = 50
@export var climbRopeSpeedDown : int = 50
@export var minLength : int = 20
@export var enableClimbUp : bool = true
@export var enableClimbDown : bool = true
#=================================================================================
func EnterState() -> void:
	player.finite_state_machine.air_resistance_lock = true
	hookSoundPlayed = false
	if player.debug_mode:
		print("Debug: Spear State")
	# Update sprite flip to the shoot direction
	player.finite_state_machine.sprite_flip_lock = true
	player.animation_player.play("ShootSpear")
	inputAmount = 0


#=================================================================================
func UpdatePhysics(delta) -> void: # Runs in _physics_process()
	if not hookSoundPlayed:
		AudioManager.play_game_sound_random(AudioManager.HOOK1, AudioManager.HOOK2)
		hookSoundPlayed = true
	#ProcessVelocity(delta)

func ExitState() -> void:
	#NOTE: removed line -- below
	#spearInstance = null
	player.finite_state_machine.sprite_flip_lock = false
	pivotPoint = Vector2.ZERO
	#player.finite_state_machine.disable_gravity = false
	player.spearCooldownTimer.start()
	inputAmount = 0
	player.finite_state_machine.air_resistance_lock = false
#=================================================================================
func ProcessVelocity(delta:float) -> void:
	drawVisual = false
	if spearInstance == null: return
	var spearToPlayer = player.spear_marker.global_position - spearInstance.global_position
	var ropeDirection : Vector2 = spearToPlayer
	
	if Input.is_action_just_pressed("SpearPull") && !player.is_on_floor():
		AudioManager.play_game_sound(AudioManager.PULLJUMP)
		spearInstance.pullReleased = true
		#if spearInstance.ropeLength > 16:
		#	spearInstance.ropeLength -= delta * 150
		player.velocity *= (1.0 - pullJumpStopFraction)
		player.velocity += -spearToPlayer.normalized() * pullJumpStrength
		return
	
	var currentRopeLength : float = ropeDirection.length()
	ropeDirection /= currentRopeLength
	
	
	#Climb Input
	var ropeLengthChange : float = 0.0
	var climbInput = Input.get_axis("Down","Up")
	if climbInput > 0.0 && enableClimbUp:
		if currentRopeLength >= minLength:
			ropeLengthChange = -climbRopeSpeedDown * delta
			#spearInstance.ropeLength -= climbRopeSpeedDown * delta
	elif climbInput < 0.0 && enableClimbDown:
		if currentRopeLength <= spearInstance.maxDistance:
			ropeLengthChange = climbRopeSpeedUp * delta
			#spearInstance.ropeLength += climbRopeSpeedUp * delta
			
	spearInstance.ropeLength += ropeLengthChange
	
	var circularArcDirection : Vector2 = Vector2(ropeDirection.y, -ropeDirection.x)
	var trueRopeLength : float = spearInstance.ropeLength
	
	drawVisual = true
	if currentRopeLength >= trueRopeLength:# || climbInput < 0.0 && enableClimbDown:
		var overextendedAmount : float = currentRopeLength - trueRopeLength
		var correctiveMovement : Vector2 = -overextendedAmount * ropeDirection
		var cachedVel = player.velocity
		
		player.velocity = correctiveMovement / delta
		player.move_and_slide()
		player.velocity = cachedVel;
		
		#fix velocity
		var velTowardsSpear : float = player.velocity.dot(-ropeDirection)
		var desiredVelTowardsSpear : float = -ropeLengthChange / delta
		var desiredVelChangeTowardsSpear : float = desiredVelTowardsSpear - velTowardsSpear
		if (desiredVelChangeTowardsSpear > 0):
			player.velocity += desiredVelChangeTowardsSpear * -ropeDirection
			
		#var desiredVel : Vector2 = player.velocity.dot(circularArcDirection) * circularArcDirection
		#var desiredVelocityChange : Vector2 = desiredVel - player.velocity
		#var tensionLevel = -desiredVelocityChange.dot(ropeDirection)
		#if (tensionLevel > 0):
			#player.velocity += desiredVelocityChange
		#Swing Input
		if player.input_axis.x != 0:
			if inputAmount <= swingSpeedCap:
				inputAmount += swingSpeedIncreaseModifier
		else:
			if inputAmount > 0:
				inputAmount -= swingSpeedDecreaseModifier
		
		if !player.is_on_floor():
			player.velocity += circularArcDirection * player.input_axis.x * inputAmount
	
	if ropeDirection.x > 0 && player.velocity.x < 0:
		player.sprite_sheet.flip_h = true
	elif ropeDirection.x < 0 && player.velocity.x > 0:
		player.sprite_sheet.flip_h = false
	
	
	
	

#=================================================================================
func AddAngularVelocity(force:float)-> void:
	angularVel += force

func AutoGrapple(spearPos : Vector2) -> void:
	var spearToPlayer = player.spear_marker.global_position - spearPos
	AudioManager.play_game_sound(AudioManager.PULLJUMP)
	if spearInstance != null:
		spearInstance.pullReleased = true
	#if spearInstance.ropeLength > 16:
	#	spearInstance.ropeLength -= delta * 150
	player.velocity *= (1.0 - pullJumpStopFraction)
	player.velocity += -spearToPlayer.normalized() * pullJumpStrength
		
