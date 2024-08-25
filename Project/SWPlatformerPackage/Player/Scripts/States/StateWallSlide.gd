class_name StateWallSlide
extends State
@onready var player = $"../.."
@onready var wall_dust_timer = $WallDustTimer

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

func Update(_delta) -> void:
	if wall_dust_timer.time_left <= 0.0:
		var dust_instance = player.instance_create(player.SLIDE_DUST_PARTICLES,player)
		dust_instance.scale.y = sign(player.velocity.y)
		dust_instance.scale.x = 0
		dust_instance.set_as_top_level(true)
		dust_instance.global_position = player.dustMarker2D.global_position + Vector2(player.last_input_direction.x*3,0) + Vector2(randi_range(0,1),0)
		wall_dust_timer.start()

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

