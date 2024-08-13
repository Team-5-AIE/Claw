class_name StateMove
extends State
@onready var player = $"../.."
# This state can transition to: Fall, Idle, Jump, Slide, Crouch
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
		
func Update(_delta) -> void:
	# Change to Idle state
	if player.input_axis.x == 0:
		player.finite_state_machine.ChangeState(player.state_idle)
		return

func Inputs(_event):
	# Change to Spear Throw state
	if player.finite_state_machine.can_we_throw_spear():
		player.finite_state_machine.ChangeState(player.state_claw)
		return

	# Change to Crouch state
	if player.finite_state_machine.can_we_crouch():
		player.velocity.x = 0
		player.finite_state_machine.ChangeState(player.state_crouch)
		return
	
	# Change to Slide state !!Important: This must be BEFORE Jump state.
	if player.finite_state_machine.can_we_slide():
		player.finite_state_machine.ChangeState(player.state_slide)
		return
	
	# Change to Jump state !!Important: This must be AFTER Slide state.
	if player.finite_state_machine.can_we_jump():
		player.finite_state_machine.ChangeState(player.state_jump)
		return

func ExitState() -> void:
	pass

