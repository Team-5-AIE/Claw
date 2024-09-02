class_name StateIdle
extends State
@onready var player = $"../.."
# This state can transition to: Move, Fall, Slide, Jump, Crouch.
# This is also the default state.
# This state happens if we are grounded and there is no input.

func EnterState() -> void:
	# Entering this state we want to reset the gounded variables 
	# and also stop the timer from wall grabbing.
	player.finite_state_machine.reset_grounded_variables()
	player.wall_grab_stamina.stop()
	if player.debug_mode:
		print("Debug: Idle State")
	player.animation_player.play("Idle")

func UpdatePhysics(_delta) -> void: # Runs in _physics_process()
	# Change to Fall state
	if !player.is_on_floor():
		player.finite_state_machine.ChangeState(player.state_fall)
		return

func Update(_delta)-> void:  # Runs in _process()
	# Change to Move state
	if player.input_axis.x != 0:
		player.finite_state_machine.ChangeState(player.state_move)
		return

func Inputs(_event):
	# Change to Spear Throw state
	if player.finite_state_machine.can_we_throw_spear():
		player.finite_state_machine.ChangeState(player.state_spear)
		return
		
	# Change to Slide state !!Important: This must be BEFORE Jump state.
	if player.finite_state_machine.can_we_slide():
		player.finite_state_machine.ChangeState(player.state_slide)
		return
	
	# Change to Jump state !!Important: This must be AFTER Slide state.
	if player.finite_state_machine.can_we_jump():
		player.finite_state_machine.ChangeState(player.state_jump)
		return
	
	# Change to Crouch state
	if player.finite_state_machine.can_we_crouch():
		player.finite_state_machine.ChangeState(player.state_crouch)
		return

func ExitState() -> void:
	pass
