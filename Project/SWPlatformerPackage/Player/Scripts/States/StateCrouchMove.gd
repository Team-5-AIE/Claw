class_name StateCrouchMove
extends State
@onready var player = $"../.."
# This state can transition to: Fall, Idle, Move Slide, Crouch Move
# This state happens if we are holding the Crouch key AND there is movement input.

func EnterState() -> void: 
	player.hitbox.disabled = true
	player.slide_hitbox.disabled = false
	if player.debug_mode:
		print("Debug: Crouch Move State")
	player.animation_player.play("CrouchMove")

func UpdatePhysics(delta) -> void: # Runs in _physics_process()
	player.velocity.x = move_toward(player.velocity.x, player.crouch_movespeed * player.input_axis.x, player.acceleration * delta)
	# Change to fall state if we are no longer grounded.
	if !player.is_on_floor():
		player.finite_state_machine.ChangeState(player.state_fall)
		return
	# Are we not holding the crouch key?
	if player.input_axis.x == 0 && !Input.is_key_pressed(player.key_crouch):
		# Are we under something?
		if player.raycast_slide_left.is_colliding() || player.raycast_slide_right.is_colliding():
			# Change to Crouch state
			player.finite_state_machine.ChangeState(player.state_crouch)
			return
		else:
			# Change to Idle state
			if !player.raycast_slide_left.is_colliding() && !player.raycast_slide_right.is_colliding():
				player.finite_state_machine.ChangeState(player.state_idle)
				return
	# Change to Crouch state if we are not moving and holding the crouch key.
	if player.input_axis.x == 0 && Input.is_key_pressed(player.key_crouch):
		player.finite_state_machine.ChangeState(player.state_crouch)
		return
	# Change to Move state if we are no longer holding crouch and are moving
	if player.input_axis.x != 0 && !Input.is_key_pressed(player.key_crouch):
		if !player.raycast_slide_left.is_colliding() && !player.raycast_slide_right.is_colliding():
			player.finite_state_machine.ChangeState(player.state_move)
			return

func Inputs(event):
	var just_pressed = event.is_pressed() && !event.is_echo()
	# Make sure we aren't under a collision that would get us stuck in the wall 
	# Before changing to jump
	if !player.raycast_slide_left.is_colliding() && !player.raycast_slide_right.is_colliding():
		# Change to Jump state
		if player.finite_state_machine.can_we_jump(event) && just_pressed:
			player.finite_state_machine.ChangeState(player.state_jump)
			return
	# Change to Slide state !!Important: This must be BEFORE Jump state.
	if player.finite_state_machine.can_we_slide(event) && just_pressed:
		player.finite_state_machine.ChangeState(player.state_slide)
		return

func ExitState() -> void:
	player.hitbox.disabled = false
	player.slide_hitbox.disabled = true
