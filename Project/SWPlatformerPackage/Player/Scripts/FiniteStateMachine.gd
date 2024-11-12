class_name FiniteStateMachine
extends Node
#References
@onready var player = $".."

#States
@export var state : State
var previous_state : State

#State variables
#Wall
var wall_climb_input : bool = false
var wall_grab_input : bool = false
var wall_jump_input : bool = false
var can_grab_wall : bool = true
var low_grab_stamina : bool = false
var out_of_stamina : bool = false
var flash_time = 0
var spearThrown = false

#Others
var sprite_flip_lock = false
var disable_gravity = false
var air_resistance_lock = false
@export var friction_lock = false

#=================================Functions===================================================
func _ready() -> void:
	ChangeState(state)

func _process(delta) -> void:
	if FadeTransitions.lockPlayer: 
		player.velocity = Vector2.ZERO
		if FadeTransitions.restart:
			player.animation_player.play("Restart")
		else:
			player.animation_player.play("Idle")
		return
	can_we_throw_spear()
	if state is State:
		state.Update(delta) # Run the UpdatePhysics function in our current state
	manage_grab_stamina()
	get_input()
	update_sprite_flip()

func _input(event) -> void:
	if FadeTransitions.lockPlayer: return
	if state is State:
		state.Inputs(event)

func _physics_process(delta) -> void:
	if FadeTransitions.lockPlayer: return
	if spearThrown:
		SpearPhysicsProcess()
	if state is State:
		state.UpdatePhysics(delta) # Run the UpdatePhysics function in our current state
	
	if !disable_gravity:
		apply_gravity(delta)
	if !player.state_jump.bunnyhop:
		apply_friction(delta)
		#if player.finite_state_machine.state != player.state_spear:
		apply_air_resistance(delta)
	# Coyote jump timing
	var was_on_floor = player.is_on_floor()
	player.move_and_slide() # This apllies movement to the player
	var just_left_ledge = was_on_floor && !player.is_on_floor() && player.velocity.y >= 0
	if just_left_ledge:
		player.coyote_jump_timer.start()

func ChangeState(newState: State) -> void:
	if state is State: # Wont run this if state is null
		state.ExitState()
	if newState is State:
		previous_state = state
		newState.EnterState()
		state = newState

func reset_grounded_variables() -> void:
	player.state_jump.bunnyhop = false
	player.wall_jump_available = true
	player.current_wall_jumps = player.max_wall_jumps
	player.jump_available = true
	player.finite_state_machine.can_grab_wall = true
	player.finite_state_machine.low_grab_stamina = false
	player.finite_state_machine.out_of_stamina = false
#====================================Apply Movement Functions========================================
func get_input() -> void:
	if !player.move_lock:
		# Wall climb key input
		if Input.is_action_pressed("WallGrab"):
			wall_grab_input = true
		else:
			wall_grab_input = false
		
		# Movement key input
		if Input.is_action_pressed("Left"):
			player.input_axis.x = -1
			wall_jump_input = true
		elif Input.is_action_pressed("Right"):
			player.input_axis.x = 1
			wall_jump_input = true
		else:
			wall_jump_input = false
			player.input_axis.x = 0
		if Input.is_action_pressed("Up"):
			player.input_axis.y = -1
			wall_climb_input = true
		elif Input.is_action_pressed("Down"):
			player.input_axis.y = 1
			wall_climb_input = true
		else:
			player.input_axis.y = 0
			wall_climb_input = false
	else:
		player.input_axis = Vector2.ZERO
	
	# Update last input direction
	if player.input_axis.x != 0: player.last_input_direction.x = player.input_axis.x
	if player.input_axis.y != 0: player.last_input_direction.y = player.input_axis.y

func update_sprite_flip() -> void:
	if !sprite_flip_lock:
		if player.input_axis.x == -1: player.sprite_sheet.flip_h = true
		elif player.input_axis.x == 1: player.sprite_sheet.flip_h = false

func apply_friction(delta) -> void:
	if player.input_axis.x == 0 && player.is_on_floor() && !friction_lock:
		if player.finite_state_machine.previous_state == player.state_slide:
			player.velocity.x = move_toward(player.velocity.x, 0, player.slide_friction * delta)
		else:
			player.velocity.x = move_toward(player.velocity.x, 0, player.friction * delta)

func apply_gravity(delta) -> void:
	if !player.is_on_floor() && player.velocity.y < player.current_max_gravity:
		player.velocity.y += player.current_gravity * delta

func apply_air_resistance(delta):
	if !player.is_on_floor() && !air_resistance_lock:
		player.velocity.x = move_toward(player.velocity.x, 0, player.air_resistance * delta)

#===========================State change checks=========================================
func jump_buffer_jump() -> bool:
	if player.jump_buffer && player.is_on_floor():
		if state == player.state_jump || state == player.state_fall || state == player.state_spear:
			if player.velocity.x >= player.run_speed || player.velocity.x <= -player.run_speed:
				player.state_jump.bunnyhop = false
		ChangeState(player.state_jump)
		return true
	return false

func can_we_throw_spear():
	if player.spearCollected:
		if state != player.state_spear && player.state_spear.spearInstance == null:
			if Input.is_action_just_pressed("Spear") && player.spearCooldownTimer.time_left <= 0.0:
				spearThrown = true

func jump_buffer_check() -> bool:
	if Input.is_action_pressed("Jump") && player.jump_enabled:
		return true
	return false

func can_we_jump() -> bool:
	if Input.is_action_just_pressed("Jump") && player.jump_enabled && player.jump_available:
		if player.coyote_jump_timer.time_left > 0.0 || player.is_on_floor() || player.can_always_jump:
			return true
	return false

func can_we_wall_jump() -> bool:
	if Input.is_action_just_pressed("Jump") && get_next_to_wall() != Vector2.ZERO && player.wall_jump_enabled && player.wall_jump_available:
		if player.current_wall_jumps > 0 || player.always_allow_wall_jumps:
			#if player.wall_grab_stamina.time_left > 0.0 || !player.wall_grab_stamina_enabled:
			return true
	return false

func can_we_crouch() -> bool:
	if Input.is_action_pressed("Crouch") && player.crouch_enabled:
		return true
	return false

func can_we_slide() -> bool:
	if player.slide_enabled && Input.is_action_just_pressed("Slide"):
		return true
	return false

func can_we_wall_climb() -> bool:
	if get_next_to_wall() != Vector2.ZERO && player.wall_climb_enabled:
		if wall_grab_input:
			if can_grab_wall || player.wall_grab_stamina.time_left > 0.0:
				return true
	return false

func can_we_wall_slide() -> bool:
	if player.finite_state_machine.state == player.state_spear: return false
	if wall_jump_input && get_next_to_wall() != Vector2.ZERO && player.wall_slide_enabled:
		if can_grab_wall || player.wall_grab_stamina.time_left > 0.0:
			return true
	return false

#==========================================Wall functions============================================
func manage_grab_stamina() -> void:
	if player.wall_climb_enabled:
		# Start Grab stamina timer if enabled
		if player.wall_grab_stamina_enabled && get_next_to_wall() != Vector2.ZERO && !player.is_on_floor():
			if player.wall_grab_stamina.time_left <= 0.0 && player.finite_state_machine.can_grab_wall:
				player.wall_grab_stamina.start()
				player.finite_state_machine.can_grab_wall = false
		
		if player.wall_grab_stamina.time_left <= 0 && !player.finite_state_machine.can_grab_wall:
			out_of_stamina = true
		if player.wall_grab_stamina.time_left <= (player.wall_grab_stamina_warning_time) && !player.finite_state_machine.can_grab_wall:
			low_grab_stamina = true
		if player.finite_state_machine.out_of_stamina:
			solid_colour_player(player.out_of_stamina_color)
		elif player.finite_state_machine.low_grab_stamina:
			flash_player()
		else:
			reset_colour_player()
	

func get_next_to_wall() -> Vector2:
	if player.raycast_top_left.is_colliding():
		return Vector2.LEFT
	elif player.raycast_top_right.is_colliding():
		return Vector2.RIGHT
	else:
		return Vector2.ZERO

func get_bottom_to_wall() -> Vector2:
	if player.raycast_bottom_left.is_colliding():
		return Vector2.LEFT
	elif player.raycast_bottom_right.is_colliding():
		return Vector2.RIGHT
	else:
		return Vector2.ZERO

func get_ledge_on_wall() -> Vector2:
	if player.raycast_top_left.is_colliding() && !player.raycast_climb_left.is_colliding():
		return Vector2.LEFT
	elif player.raycast_top_right.is_colliding() && !player.raycast_climb_right.is_colliding():
		return Vector2.RIGHT
	else:
		return Vector2.ZERO

func flash_player() -> void:
	flash_time += 0.1
	var value = (sin(flash_time - PI)/2) + 1.0 / 2.0
	player.sprite_sheet.modulate = player.low_stamina_flash_color.gradient.sample(value)
	
func solid_colour_player(col) -> void:
	player.sprite_sheet.modulate = col

func reset_colour_player() -> void:
	player.sprite_sheet.modulate = Color.WHITE
	flash_time = 0

#=========================================Timer timeouts====================================
func _on_jump_buffer_timer_timeout():
	player.jump_buffer = false

func SpearPhysicsProcess() -> void:
	player.sprite_sheet.texture = player.PLAYER_SHEET_NO_SPEAR
	#Create Spear
	player.state_spear.spearInstance = player.state_spear.SPEAR.instantiate()
	# Get direction to shoot in
	player.state_spear.shootDirection = (player.get_global_mouse_position() - player.spear_marker.global_position)
	
	if sign(player.state_spear.shootDirection.x) == 1:
		player.sprite_sheet.flip_h = false
		player.state_spear.spearInstance.flipped = false
	else:
		player.sprite_sheet.flip_h = true
		player.state_spear.spearInstance.flipped = true
	
	# Spear Set up
	player.state_spear.add_child(player.state_spear.spearInstance)
	player.state_spear.spearInstance.audio_stream_player = player.audio_stream_player
	player.state_spear.spearInstance.player = player
	player.state_spear.spearInstance.global_position = player.spear_marker.global_position
	player.state_spear.spearInstance.Shoot(player.state_spear.shootDirection)
	spearThrown = false
