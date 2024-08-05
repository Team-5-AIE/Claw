class_name StateClaw
extends State
@onready var player = $"../.."
const CLAW = preload("res://Objects/claw.tscn")
@export var CLAW_PULL : float = 20.0
var clawInstance
@export var clawVelSpeed : float = 0.7
var shootDirection : Vector2 = Vector2.ZERO
@export var swingSpeed : float = 50
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
func EnterState() -> void:
	correctionNeeded = true
	if player.debug_mode:
		print("Debug: Claw State")
	player.animation_player.play("ShootClaw")
	if player.is_on_floor():
		player.legs_air.visible = false
		player.legs_ground.visible = true
	else:
		player.legs_air.visible = true
		player.legs_ground.visible = false
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
		player.legs_air.flip_h = false
		player.legs_ground.flip_h = false
	else:
		player.claw_marker.global_position = player.global_position + Vector2(6,-28)
		player.sprite_sheet.flip_h = true
		clawInstance.flipped = true
		player.legs_air.flip_h = true
		player.legs_ground.flip_h = true
	#Create claw and set it up
	
	
	add_child(clawInstance)
	clawInstance.player = player
	clawInstance.global_position = player.claw_marker.global_position
	clawInstance.Shoot(shootDirection)

func UpdatePhysics(delta) -> void: # Runs in _physics_process()
	if clawInstance.hooked:
		ProcessVelocity(delta)
		player.legs_air.visible = true
		player.legs_ground.visible = false
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
	player.legs_air.visible = false
	player.legs_ground.visible = false

func SetStartPosition(start:Vector2,end:Vector2) -> void:
	pass
	#print("startpos")
	#pivotPoint = start
	#endPos = end
	#length = clawInstance.ropeLength
	#angle = -start.angle_to_point(end) + deg_to_rad(-90)
	#angularVel = 0.0
	#angularAcceleration = 0.0

func ProcessVelocity(delta:float) -> void:
	if Input.is_action_pressed("ClawPull"):
		if clawInstance.ropeLength > 16:
			clawInstance.ropeLength -= delta * 150
	
	var clawToPlayer = player.claw_marker.global_position - clawInstance.global_position
	var ropeDirection : Vector2 = clawToPlayer
	
	
	#var currentRopeLength : float = sqrt(ropeDirection.x * ropeDirection.x + ropeDirection.y * ropeDirection.y)
	#ropeDirection /= currentRopeLength
	
	var currentRopeLength : float = ropeDirection.length()
	ropeDirection /= currentRopeLength
	
	#var vel : Vector2
	#print(ropeDirection)
	
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
	
	#angularAcceleration = ((gravity*delta) / clawInstance.ropeLength) * sin(angle)
	#angularVel += angularAcceleration
	#angularVel *= damping
	#angle += angularVel
	#endPos only used for drawing the white line - 
	# -- player should be at the end of it with correct velocity calculations
	#endPos = pivotPoint - Vector2(sin(angle), cos(angle)) * clawInstance.ropeLength
	
	#player.global_position = endPos
	# If the player is holding down left or right - add force for swing
	#if player.input_axis.x != 0:
	#	AddAngularVelocity(sign(player.input_axis.x)* 0.001)
	
	# Apply velocity to player based on calculations
	#var tanSpeed = angularVel * clawInstance.ropeLength
	#var velDir = Vector2(-cos(angle),sin(angle)) 
	#player.velocity = velDir * tanSpeed * swingSpeed
	
	#if Input.is_action_pressed("Down"):
	#if correctionNeeded:
		#var offsetVelocity = (pivotPoint - endPos).normalized() * length
		#player.velocity.x += offsetVelocity.x
		
		#check if we have corrected the movement
		#if #position is corrected:
		#	correctionNeeded = false
		#	print("correction finished")


func AddAngularVelocity(force:float)-> void:
	angularVel += force
