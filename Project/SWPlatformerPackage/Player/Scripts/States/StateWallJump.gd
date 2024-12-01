class_name StateWallJump
extends State
@onready var player = $"../.."
# This state can transition to: Double jump, Dash, Fall.
# This state happens if we have pressed the Jump key.
var jump_direction : Vector2 = Vector2(1,0)

func EnterState() -> void:
	var dust_instance = player.instance_create(player.RUN_DUST_PARTICLES,player)
	dust_instance.scale.x = sign(-player.velocity.x)
	dust_instance.set_as_top_level(true)
	dust_instance.global_position = player.dustMarker2D.global_position + Vector2(sign(player.velocity.x) * 3,0)
	
	if !player.always_allow_wall_jumps:
		player.current_wall_jumps -= 1
		if player.current_wall_jumps == 0:
			player.wall_jump_available = false
	var horizontalSpeedOfThisWallJump = player.wall_jump_speed
	if player.state_jump.bunnyhop:
		var signCheckVelocity = sign(player.velocity.x)
		if signCheckVelocity == 1:
			horizontalSpeedOfThisWallJump = -player.state_jump.initVel.x
		elif signCheckVelocity == -1:
			horizontalSpeedOfThisWallJump = player.state_jump.initVel.x
	# Get direction to jump in
	if player.finite_state_machine.get_next_to_wall() == Vector2.LEFT:
		player.velocity.x = horizontalSpeedOfThisWallJump
	if player.finite_state_machine.get_next_to_wall() == Vector2.RIGHT:
		player.velocity.x = -horizontalSpeedOfThisWallJump #NOTE: Invalid assignment of property or key 'x' with value of type Vector2 on base object of type "Vector2"
	player.velocity.y = -player.jump_height
	if player.finite_state_machine.get_next_to_wall() == Vector2.RIGHT:
		player.sprite_sheet.flip_h = true
	elif player.finite_state_machine.get_next_to_wall() == Vector2.LEFT:
		player.sprite_sheet.flip_h = false
	if player.debug_mode:
		print("Debug: Wall Jump State")
	player.animation_player.play("WallJump")
	player.last_input_direction.x = -player.last_input_direction.x
	AudioManager.play_game_sound_random(-5, AudioManager.JUMP1, AudioManager.JUMP2, AudioManager.JUMP3)

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


func Inputs(_event):
	# Change to Wall Jump State
	if player.finite_state_machine.can_we_wall_jump():
		player.finite_state_machine.ChangeState(player.state_wall_jump)
		return

func ExitState() -> void:
	pass
