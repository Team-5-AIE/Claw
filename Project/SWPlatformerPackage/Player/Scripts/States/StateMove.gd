class_name StateMove
extends State
@onready var player = $"../.."
# This state can transition to: Fall, Idle, Jump, Slide, Crouch, Dash
# This state happens if we are grounded and there IS movement input.

func EnterState() -> void: 
	if player.debug_mode:
		print("Debug: Move State")
	player.animation_player.play("Run")

func UpdatePhysics(delta) -> void: # Runs in _physics_process()
	player.velocity.x = move_toward(player.velocity.x, player.run_speed * player.input_axis.x, player.acceleration * delta)
	# Change to Fall state if we are no longer grounded
	if !player.is_on_floor():
		player.finite_state_machine.ChangeState(player.state_fall)
		return
	# Change to Idle state
	if player.input_axis.x == 0:
		player.finite_state_machine.ChangeState(player.state_idle)
		return
	# Change to Crouch Move State
	if player.finite_state_machine.can_we_crouch_move():
		player.finite_state_machine.ChangeState(player.state_crouch_move)
		return

func Inputs(event):
	if Input.is_action_just_pressed("Claw") && player.spearCooldownTimer.time_left <= 0.0:
		player.finite_state_machine.ChangeState(player.state_claw)
	var just_pressed = event.is_pressed() && !event.is_echo()
	# Change to Crouch state
	if player.finite_state_machine.can_we_crouch(event) && just_pressed && !player.crouch_walk_enabled:
		player.velocity.x = 0
		player.finite_state_machine.ChangeState(player.state_crouch)
		return
	# Change to Slide state !!Important: This must be BEFORE Jump state.
	if player.finite_state_machine.can_we_slide(event) && just_pressed:
		player.finite_state_machine.ChangeState(player.state_slide)
		return
	# Change to Jump state !!Important: This must be AFTER Slide state.
	if player.finite_state_machine.can_we_jump(event) && just_pressed:
		player.finite_state_machine.ChangeState(player.state_jump)
		return
	# Change to Dash State
	if player.finite_state_machine.can_we_dash(event) && just_pressed:
		player.finite_state_machine.ChangeState(player.state_dash)
		return

func ExitState() -> void:
	pass

