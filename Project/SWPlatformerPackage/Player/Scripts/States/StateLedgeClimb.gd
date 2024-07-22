class_name StateLedgeClimb
extends State
@onready var player = $"../.."
var dir = 0

func EnterState() -> void:
	player.velocity = Vector2.ZERO
	
	# Set up for climb
	if player.finite_state_machine.get_next_to_wall() == Vector2.RIGHT:
		player.sprite_sheet.flip_h = false
		dir = 1
	elif player.finite_state_machine.get_next_to_wall() == Vector2.LEFT:
		player.sprite_sheet.flip_h = true
		dir = -1
	player.global_position += Vector2(dir * 10,-26)
	player.finite_state_machine.sprite_flip_lock = true
	if player.debug_mode:
		print("Debug: Ledge Climb State")
	player.animation_player.play("LedgeClimb")	
	
func UpdatePhysics(_delta)-> void:  # Runs in _physics_process()
	if player.animation_end:
		player.finite_state_machine.ChangeState(player.state_idle)
		return


func Inputs(_event) -> void:  # Runs in _process()
	return

func ExitState() -> void:
	player.finite_state_machine.sprite_flip_lock = false
	player.velocity = Vector2.ZERO

