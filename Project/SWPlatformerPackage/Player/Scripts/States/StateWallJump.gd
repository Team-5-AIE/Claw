class_name StateWallJump
extends State
@onready var player = $"../.."
# This state can transition to: Double jump, Dash, Fall.
# This state happens if we have pressed the Jump key.
var jump_direction : Vector2 = Vector2(1,0)
func EnterState() -> void:
	if !player.always_allow_wall_jumps:
		player.current_wall_jumps -= 1
		if player.current_wall_jumps == 0:
			player.wall_jump_available = false
	var horizontalSpeedOfThisWallJump = player.wall_jump_speed
	if player.state_jump.bunnyhop:
		var signCheckVelocity = sign(player.velocity.x)
		if signCheckVelocity == 1:
			horizontalSpeedOfThisWallJump = -player.state_jump.initVel
		elif signCheckVelocity == -1:
			horizontalSpeedOfThisWallJump = player.state_jump.initVel
	# Get direction to jump in
	if player.finite_state_machine.get_next_to_wall() == Vector2.LEFT:
		player.velocity.x = horizontalSpeedOfThisWallJump
	if player.finite_state_machine.get_next_to_wall() == Vector2.RIGHT:
		player.velocity.x = -horizontalSpeedOfThisWallJump
	player.velocity.y = -player.jump_height
	if player.finite_state_machine.get_next_to_wall() == Vector2.RIGHT:
		player.sprite_sheet.flip_h = true
	elif player.finite_state_machine.get_next_to_wall() == Vector2.LEFT:
		player.sprite_sheet.flip_h = false
	if player.debug_mode:
		print("Debug: Wall Jump State")
	player.animation_player.play("WallJump")

func UpdatePhysics(delta)-> void:  # Runs in _physics_process()
	if player.input_axis.x != 0 && !player.state_jump.bunnyhop:
		player.velocity.x = move_toward(player.velocity.x, player.run_speed * player.input_axis.x, player.air_acceleration * delta)
	
	# Set to fall state if we hit the roof of a collision
	if player.is_on_ceiling():
		player.finite_state_machine.ChangeState(player.state_fall)
	
	# Are we in the air and finished jumping?
	if !player.is_on_floor() && player.velocity.y > 0:
		# Change to Fall state
		player.finite_state_machine.ChangeState(player.state_fall)
		return
		
	if player.animation_end && player.is_on_floor():
		player.finite_state_machine.ChangeState(player.state_idle)
		return
	## Change to Wall Climb state #NOTE: test if needed or can be nuked
	#if player.finite_state_machine.can_we_wall_climb():
		#player.finite_state_machine.ChangeState(player.state_wall_climb)
		#return


func Inputs(event):
	# Change to Spear Throw state
	if player.finite_state_machine.can_we_throw_spear():
		player.finite_state_machine.ChangeState(player.state_claw)
		return
	
	# Change to Wall Jump State
	if player.finite_state_machine.can_we_wall_jump():
		player.finite_state_machine.ChangeState(player.state_wall_jump)
		return

func ExitState() -> void:
	pass

