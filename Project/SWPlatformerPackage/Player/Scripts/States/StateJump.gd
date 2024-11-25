class_name StateJump
extends State
@onready var player = $"../.."
var half_jump = false
var crouch_jumping = false
var bunnyhop = false
var initVel : Vector2 = Vector2.ZERO
# This state can transition to: Double jump, Dash, Fall.
# This state happens if we have pressed the Jump key.

func EnterState() -> void:
	
	
	var dust_instance = player.instance_create(player.RUN_DUST_PARTICLES,player)
	dust_instance.scale.x = sign(-player.velocity.x)
	dust_instance.set_as_top_level(true)
	dust_instance.global_position = player.dustMarker2D.global_position + Vector2(sign(player.velocity.x) * 3,0)
	if bunnyhop:
		print("bunnyhop")
		AudioManager.play_game_sound(AudioManager.PULLJUMP, 0)
	else:
		AudioManager.play_game_sound_random(0, AudioManager.JUMP1, AudioManager.JUMP2, AudioManager.JUMP3)
		print("normal jump")
	initVel = player.velocity
	half_jump = false
	player.jump_available = false
	if crouch_jumping:
		player.velocity.y = -player.crouch_jump_height # Apply jump velocity
	else:
		player.velocity.y = -player.jump_height # Apply jump velocity
	if player.debug_mode:
		print("Debug: Jump State")
	player.animation_player.play("Jump")

func UpdatePhysics(delta)-> void:  # Runs in _physics_process()
	if player.velocity.y < -player.jump_height/2 && !player.is_on_floor() && bunnyhop:
		player.velocity.y = -player.jump_height/2
		half_jump = true
	if player.input_axis.x != 0:
		if bunnyhop:
			BunnyHopMovement(player.input_axis.x)
		else:
			player.velocity.x = move_toward(player.velocity.x, player.run_speed * player.input_axis.x, player.air_acceleration * delta)
	# Set to fall state if we hit the roof of a collision
	if player.is_on_ceiling():
		player.finite_state_machine.ChangeState(player.state_fall)
	# Are we in the air and finished jumping?
	if !player.is_on_floor() && player.velocity.y >= 0:
			# Change to Fall state
			player.finite_state_machine.ChangeState(player.state_fall)
			return
	# Change to Wall Climb state
	if player.finite_state_machine.can_we_wall_climb():
		player.finite_state_machine.ChangeState(player.state_wall_climb)
		return
	# Change to Idle state
	if player.is_on_floor() && player.animation_end:
		player.velocity.y = 0
		player.finite_state_machine.ChangeState(player.state_idle)
		return
	

func Inputs(event):
	var just_pressed = event.is_pressed() && !event.is_echo()
	
	# Variable Jump
	if event is InputEventKey and not event.pressed:
		if Input.is_action_just_released("Jump") && !bunnyhop:
			if crouch_jumping:
				if player.velocity.y < -player.crouch_jump_height/2 && !player.is_on_floor():
					player.velocity.y = -player.crouch_jump_height/2
					half_jump = true
			else:
				if player.velocity.y < -player.jump_height/2 && !player.is_on_floor():
					player.velocity.y = -player.jump_height/2
					half_jump = true
	# Change to Wall Jump State
	if player.finite_state_machine.can_we_wall_jump() && just_pressed:
		player.finite_state_machine.ChangeState(player.state_wall_jump)
		return


func ExitState() -> void:
	crouch_jumping = false

func BunnyHopMovement(input):
	if input > 0: #Right
		if sign(initVel.x) == -1:
			player.velocity.x = -initVel.x
			#if player.velocity.x > player.run_speed:
			#	player.velocity.x = player.run_speed
		elif sign(initVel.x) == 1:
			pass
		
		print("RIGHT")
	
	if input < 0: #Left
		if sign(initVel.x) == -1:
			pass
		elif sign(initVel.x) == 1:
			player.velocity.x = -initVel.x
			#if player.velocity.x < player.run_speed:
			#	player.velocity.x = player.run_speed
		print("LEFT")
