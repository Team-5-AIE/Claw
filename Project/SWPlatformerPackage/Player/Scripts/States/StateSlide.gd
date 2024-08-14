class_name StateSlide
extends State
@onready var player = $"../.."
var sliding : bool = true
var slide_direction : int
@onready var slide_dust_timer = $SlideDustTimer

# This state can transition to: Idle, Fall, Jump, Crouch
# This state happens if have pressed the Slide key.

func EnterState() -> void:
	player.move_lock = true
	player.hitbox.disabled = true
	player.slide_hitbox.disabled = false
	player.finite_state_machine.sprite_flip_lock = true
	player.slide_timer.start()
	sliding = true
	slide_direction = player.last_input_direction.x
	if player.debug_mode:
		print("Debug: Slide State")
	player.animation_player.play("Slide")

func UpdatePhysics(_delta)-> void:  # Runs in _physics_process()
	if slide_dust_timer.time_left <= 0.0:
		var dust_instance = player.instance_create(player.SLIDE_DUST_PARTICLES,player)
		dust_instance.scale.x = sign(player.velocity.x)
		dust_instance.set_as_top_level(true)
		dust_instance.global_position = player.dustMarker2D.global_position + Vector2(0, randi_range(0,1))
		slide_dust_timer.start()
	if sliding: # Stop sliding if timer reaches 0 and we aren't currently sliding under something
		if player.slide_timer.time_left <= 0.0 && !player.raycast_slide_left.is_colliding() && !player.raycast_slide_right.is_colliding():
			sliding = false
		if !player.is_on_floor(): # Stop sliding if we're not grounded
			sliding = false
	
	# Otherwise - enable sliding
	if sliding:
		player.velocity.x = slide_direction * player.slide_speed
		if player.raycast_bottom_left.is_colliding():
			if player.sprite_sheet.flip_h == false:
				player.velocity.y = player.slide_speed
		if player.raycast_bottom_right.is_colliding():
			if player.sprite_sheet.flip_h == true:
				player.velocity.y = player.slide_speed
			
	
	# Return to Idle state if slide has finished.
	if !sliding && player.is_on_floor():
		player.finite_state_machine.ChangeState(player.state_idle)
		return
	
	# Change to Fall state if we are no longer grounded
	if !player.is_on_floor():
		player.finite_state_machine.ChangeState(player.state_fall)
		return

func Inputs(_event):
	# Change to Jump state
	if player.finite_state_machine.can_we_jump() && player.slide_timer.time_left <= player.slide_time - player.slide_jump_time_lockout:
		if !player.raycast_slide_left.is_colliding() && !player.raycast_slide_right.is_colliding():
			sliding = false
			player.state_jump.bunnyhop = true
			player.finite_state_machine.ChangeState(player.state_jump)
			return
	# Change to Crouch state
	if player.finite_state_machine.can_we_crouch() && player.cancel_slide_to_crouch_enabled:
		player.velocity.x = 0
		player.finite_state_machine.ChangeState(player.state_crouch)
		return

func ExitState() -> void:
	player.finite_state_machine.sprite_flip_lock = false
	player.hitbox.disabled = false
	player.slide_hitbox.disabled = true
	player.move_lock = false
