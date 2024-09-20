class_name StateMove
extends State
@onready var player = $"../.."
@onready var run_dust_timer = $RunDustTimer

# This state can transition to: Fall, Idle, Jump, Slide, Crouch
# This state happens if we are grounded and there IS movement input.
@onready var audio_stream_player: AudioStreamPlayer = $"../../AudioStreamPlayer"
@onready var footstep_sound_timer: Timer = $"../../Timers/FootstepSoundTimer"
const STEPS1 = preload("res://Sounds/Effects/steps1.wav")
const STEPS2 = preload("res://Sounds/Effects/steps2.wav")
const STEPS3 = preload("res://Sounds/Effects/steps3.wav")

func EnterState() -> void: 
	PlayFootsteps()
	footstep_sound_timer.start()
	if player.debug_mode:
		print("Debug: Move State")
	player.animation_player.play("Run")

func UpdatePhysics(delta) -> void: # Runs in _physics_process()
	player.finite_state_machine.move_player(delta, false)
	if player.velocity.x != 0 && run_dust_timer.time_left <= 0:
		var dust_instance = player.instance_create(player.RUN_DUST_PARTICLES,player)
		dust_instance.scale.x = sign(-player.velocity.x)
		dust_instance.set_as_top_level(true)
		dust_instance.global_position = player.dustMarker2D.global_position + Vector2(sign(player.velocity.x) * 3,0)
		run_dust_timer.start()
	# Change to Fall state if we are no longer grounded
	if !player.is_on_floor():
		player.finite_state_machine.ChangeState(player.state_fall)
		return
		
func Update(_delta) -> void:
	# Change to Idle state
	if player.input_axis.x == 0:
		player.finite_state_machine.ChangeState(player.state_idle)
		return

func Inputs(_event):
	# Change to Crouch state
	if player.finite_state_machine.can_we_crouch():
		player.velocity.x = 0
		player.finite_state_machine.ChangeState(player.state_crouch)
		return
	
	# Change to Slide state !!Important: This must be BEFORE Jump state.
	if player.finite_state_machine.can_we_slide():
		player.finite_state_machine.ChangeState(player.state_slide)
		return
	
	# Change to Jump state !!Important: This must be AFTER Slide state.
	if player.finite_state_machine.can_we_jump():
		player.finite_state_machine.ChangeState(player.state_jump)
		return

func ExitState() -> void:
	audio_stream_player.stop()
	footstep_sound_timer.stop()

func PlayFootsteps():
	var randSound = randi_range(0,2)
	match randSound:
		0: audio_stream_player.stream = STEPS1
		1: audio_stream_player.stream = STEPS2
		2: audio_stream_player.stream = STEPS3
	audio_stream_player.play()
	if player.finite_state_machine.state == player.state_move:
		footstep_sound_timer.start()
