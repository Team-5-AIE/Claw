class_name StateWallSlide
extends State
@onready var player = $"../.."

func EnterState() -> void:
	player.wall_grab_stamina.paused = false
	if player.debug_mode:
		print("Debug: Wall Slide State")
	if player.finite_state_machine.get_next_to_wall() == Vector2.RIGHT:
		player.sprite_sheet.flip_h = true
	elif player.finite_state_machine.get_next_to_wall() == Vector2.LEFT:
		player.sprite_sheet.flip_h = false
	player.finite_state_machine.sprite_flip_lock = true
	player.animation_player.play("WallSlide")
	
func UpdatePhysics(delta)-> void:  # Runs in _physics_process()
	player.animation_player.play("WallSlide") #NOTE: Needed? or can just loop the animation?
	player.velocity.x = move_toward(player.velocity.x, player.run_speed * player.input_axis.x, player.acceleration * delta)
	
	# Change to Land state
	if player.is_on_floor():
		player.finite_state_machine.ChangeState(player.state_land)
		return
	# Change to Fall state 
	if player.finite_state_machine.get_next_to_wall() == Vector2.ZERO:
		player.finite_state_machine.ChangeState(player.state_fall)
		return
	if !player.finite_state_machine.wall_grab_input && !player.finite_state_machine.wall_jump_input:
		player.finite_state_machine.ChangeState(player.state_fall)
		return
	if player.wall_grab_stamina.time_left <= 0.0 && !player.finite_state_machine.can_grab_wall:
		player.finite_state_machine.ChangeState(player.state_fall)
		return
	# Change to Wall Climb state 
	if player.finite_state_machine.wall_grab_input && player.finite_state_machine.wall_jump_input:
		if player.wall_climb_enabled:
			player.finite_state_machine.ChangeState(player.state_wall_climb)
			return
	# Slide character faster down if pressing down key
	if !player.input_axis.y > 0:
		player.velocity.y *= player.wall_slide_friction

func Inputs(_event) -> void:  # Runs in _process()
	# Change to Spear Throw state
	if player.finite_state_machine.can_we_throw_spear():
		player.finite_state_machine.ChangeState(player.state_claw)
		return
	
	# Change to Wall Jump State
	if player.finite_state_machine.can_we_wall_jump():
		player.finite_state_machine.ChangeState(player.state_wall_jump)
		return

func ExitState() -> void:
	player.finite_state_machine.sprite_flip_lock = false
	player.wall_grab_stamina.paused = true

