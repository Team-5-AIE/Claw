class_name StateCrouch
extends State
@onready var player = $"../.."
# This state can transition to: Idle, Move, Slide, Crouch Move
# This state happens if we are holding the Crouch key but there is no movement input.

func EnterState() -> void: 
	player.hitbox.disabled = true
	player.slide_hitbox.disabled = false
	if player.debug_mode:
		print("Debug: Crouch State")
	player.animation_player.play("Crouch")


func UpdatePhysics(_delta) -> void: # Runs in _physics_process()
	# Make sure we aren't under a collision that would get us stuck in the wall 
	# Before changing to idle or move
	if !player.raycast_slide_left.is_colliding() && !player.raycast_slide_right.is_colliding():
		# Change to Idle State
		if player.input_axis.x == 0 && !Input.is_action_pressed("Crouch"):
			player.finite_state_machine.ChangeState(player.state_idle)
			return
		# Change to Move State
		if player.input_axis.x != 0 && !Input.is_action_pressed("Crouch"):
			player.finite_state_machine.ChangeState(player.state_move)
			return
	#NOTE: remove but need a new case for under something and not sliding
	#	# Change to Crouch Move State
	#	if player.finite_state_machine.can_we_crouch_move() :
	#		player.finite_state_machine.ChangeState(player.state_crouch_move)
	#		return
	#else: # Crouch move even if we aren't holding down crouch because we are under something
	#	if player.input_axis.x != 0 && player.crouch_walk_enabled:
	#		player.finite_state_machine.ChangeState(player.state_crouch_move)
	#		return

func Inputs(_event) -> void:
	# Make sure we aren't under a collision that would get us stuck in the wall 
	# Before changing to jump
	if !player.raycast_slide_left.is_colliding() && !player.raycast_slide_right.is_colliding():
		# Change to Jump state
		if player.finite_state_machine.can_we_jump():
			player.state_jump.crouch_jumping = true
			player.finite_state_machine.ChangeState(player.state_jump)
			return
	# Change to Slide state
	if player.finite_state_machine.can_we_slide():
		player.finite_state_machine.ChangeState(player.state_slide)
		return

func ExitState() -> void:
	player.hitbox.disabled = false
	player.slide_hitbox.disabled = true
