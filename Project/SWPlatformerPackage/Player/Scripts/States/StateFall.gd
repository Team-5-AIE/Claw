class_name StateFall
extends State
@onready var player = $"../.."
var jumpedFromSpear = false
# This state can transition to: Land, Jump, 
# This state happens if we are not grounded.
func EnterState() -> void:
	if player.debug_mode:
		print("Debug: Fall State")
	if jumpedFromSpear:
		player.velocity.y = -player.jump_height
	player.animation_player.play("Fall")
	
	if player.finite_state_machine.previous_state == player.state_spear:
		var dust_instance = player.instance_create(player.RUN_DUST_PARTICLES,player)
		dust_instance.scale.x = sign(-player.velocity.x)
		dust_instance.set_as_top_level(true)
		dust_instance.global_position = player.dustMarker2D.global_position

func UpdatePhysics(delta)-> void:  # Runs in _physics_process()
	player.finite_state_machine.move_player(delta, true)
	
	# Jump buffer #NOTE: why is this here?
	if player.finite_state_machine.jump_buffer_jump():
		return
	
	# Change to Land state
	if player.is_on_floor():
		player.finite_state_machine.ChangeState(player.state_land)
		return

	# Change to Wall Climb state
	if player.finite_state_machine.can_we_wall_climb():
		player.finite_state_machine.ChangeState(player.state_wall_climb)
		return
	
	# Change to Wall Slide state
	if player.finite_state_machine.can_we_wall_slide():
		player.finite_state_machine.ChangeState(player.state_wall_slide)
		return


func Inputs(_event):
	# Jump buffer Check
	if player.finite_state_machine.jump_buffer_check():
		player.jump_buffer = true
		player.jump_buffer_timer.start()
	
	# Change to Wall Jump State
	if player.finite_state_machine.can_we_wall_jump():
		player.finite_state_machine.ChangeState(player.state_wall_jump)
		return
	
	# Change to Jump state
	if player.finite_state_machine.can_we_jump():
		player.finite_state_machine.ChangeState(player.state_jump)
		return

func ExitState() -> void:
	jumpedFromSpear = false
