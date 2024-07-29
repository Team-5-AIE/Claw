class_name StateClaw
extends State
@onready var player = $"../.."
const CLAW = preload("res://Objects/claw.tscn")
@export var CLAW_PULL : float = 20.0
var clawInstance
@export var clawVelSpeed : float = 0.7
var shootDirection : Vector2 = Vector2.ZERO

#Physics pendulum stuff
var pivotPoint : Vector2 = Vector2.ZERO #point the pengulum rotates around
var endPos : Vector2 #global_position
var length : float # get the angle between position + godot angle offset
var gravity =  0.4 * 60
var angle
var damping = 0.995
var angularVel : float = 0.0
var angularAcceleration : float = 0.0

func EnterState() -> void:
	if player.debug_mode:
		print("Debug: Claw State")
	player.animation_player.play("ShootClaw")
	# Get direction to shoot in
	shootDirection = (player.get_global_mouse_position() - player.claw_marker.global_position)
	# Update sprite flip to the shoot direction
	player.finite_state_machine.sprite_flip_lock = true
	if sign(shootDirection.x) == 1:
		player.sprite_sheet.flip_h = false
	else:
		player.sprite_sheet.flip_h = true
	#Create claw and set it up
	clawInstance = CLAW.instantiate()
	add_child(clawInstance)
	clawInstance.player = player
	clawInstance.global_position = player.claw_marker.global_position
	clawInstance.Shoot(shootDirection)

func UpdatePhysics(delta) -> void: # Runs in _physics_process()
	if clawInstance.hooked:
		#player.finite_state_machine.disable_gravity = true
		# Pull player towards claw
		if Input.is_action_pressed("ClawPull"):
			if clawInstance.distanceToPlayer >= 30:
				#length -= clawVelSpeed
				#var dir = (clawInstance.global_position - player.claw_marker.global_position).normalized()
				ProcessVelocity(delta)
				return
		# Dangle physics
		ProcessVelocity(delta)
	else:
		# We haven't hooked the claw - free movement
		if player.is_on_floor():
			player.velocity.x = move_toward(player.velocity.x, player.run_speed * player.input_axis.x, player.acceleration * delta)
func Inputs(event) -> void:
	pass

func ExitState() -> void:
	clawInstance.queue_free()
	player.finite_state_machine.sprite_flip_lock = false
	pivotPoint = Vector2.ZERO
	#player.finite_state_machine.disable_gravity = false

func SetStartPosition(start:Vector2,end:Vector2) -> void:
	print("startpos")
	#pivotPoint = start
	#endPos = end
	#length = clawInstance.distanceToPlayer
	#angle = -start.angle_to_point(end) + deg_to_rad(-90)
	#angularVel = 0.0
	#angularAcceleration = 0.0

func ProcessVelocity(delta:float) -> void:
	
	var clawToPlayer = player.global_position - clawInstance.global_position
	var ropeDirection : Vector2 = clawToPlayer.normalized()
	
	var offset = player.global_position - player.claw_marker.global_position
	var startPos = player.global_position-clawInstance.global_position - offset
	var endPos = Vector2.ZERO
	var currentRopeLength : float = startPos.distance_to(endPos)
	var vel : Vector2
	
	
	var circularArcDirection : Vector2 = ropeDirection - Vector2.RIGHT.rotated(90)
	var trueRopeLength : float = clawInstance.ropeLength
	
	if currentRopeLength > trueRopeLength:
		var overextendedAmount : float = trueRopeLength - currentRopeLength
		var correctiveMovement : Vector2 = overextendedAmount * ropeDirection 
		#move and slide by corrective movement to fix that
		#fix velocity
		if ropeDirection.dot(player.velocity) > 0:
			vel = vel.dot(circularArcDirection) * circularArcDirection
		player.velocity += vel + correctiveMovement 
	if player.input_axis.x != 0:
		player.velocity.x += player.input_axis.x * 10
	#angularAcceleration = ((gravity*delta) / length) * sin(angle)
	#angularVel += angularAcceleration
	#angularVel *= damping
	#angle += angularVel
	#endPos only used for drawing the white line - 
	# -- player should be at the end of it with correct velocity calculations
	#endPos = pivotPoint - Vector2(length*sin(angle), length*cos(angle))
	
	#player.global_position = endPos
	# If the player is holding down left or right - add force for swing
	#if player.input_axis.x != 0:
	#	AddAngularVelocity(sign(player.input_axis.x)* 0.001)
	
	# Apply velocity to player based on calculations
	#var tanVel = angularVel * length
	#var velDir = Vector2(-cos(angle),sin(angle)) 
	#player.velocity = velDir * tanVel *50
	
	#var offsetVelocity = (pivotPoint - player.position).normalized() * length
	#player.velocity.x += offsetVelocity.x


func AddAngularVelocity(force:float)-> void:
	angularVel += force
