class_name StateLand
extends State
@onready var player = $"../.."
# This state can transition to: Land, Glide, Dash, Jump, Double Jump
# This state happens when we have just become grounded.

func EnterState() -> void:
	player.finite_state_machine.reset_grounded_variables()
	player.wall_grab_stamina.stop()
	if player.debug_mode:
		print("Debug: Land State")
	player.animation_player.play("Land")
	
func UpdatePhysics(delta)-> void:  # Runs in _physics_process()
	player.finite_state_machine.move_player(delta, false)

func Update(_delta) -> void: # Runs in _process()
	# Change state to Idle
	if player.animation_end:
		player.finite_state_machine.ChangeState(player.state_idle)
		return
	# Change to Move state
	if player.input_axis.x != 0:
		player.finite_state_machine.ChangeState(player.state_move)
		return

func Inputs(_event):
	# Change to Slide state - !!Important: This must be before Jump state.
	if player.finite_state_machine.can_we_slide():
		player.finite_state_machine.ChangeState(player.state_slide)
		return
	
	# Change to Jump state
	if player.finite_state_machine.can_we_jump():
		player.finite_state_machine.ChangeState(player.state_jump)
		return
	
	# Change to Crouch state
	if player.finite_state_machine.can_we_crouch():
		player.finite_state_machine.ChangeState(player.state_crouch)
		return

func ExitState() -> void:
	pass
