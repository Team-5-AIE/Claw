class_name TraveenStateClawEdits
extends StateSpear

const NEW_CLAW = preload("res://DesignPrototypes/TraveenProposals/TraveenProtoClaw.tscn")

func EnterState() -> void:
	if player.debug_mode:
		print("Debug: Claw State")
	player.animation_player.play("ShootClaw")
	# Get direction to shoot in
	shootDirection = (player.get_global_mouse_position() - player.claw_marker.global_position)
	# Update sprite flip to the shoot direction
	player.finite_state_machine.sprite_flip_lock = true
	if sign(shootDirection.x) == 1:
		player.sprite_sheet.flip_h = false
	else:
		player.sprite_sheet.flip_h = true
	#Create claw and set it up
	clawInstance = NEW_CLAW.instantiate()
	add_child(clawInstance)
	clawInstance.player = player
	clawInstance.global_position = player.claw_marker.global_position
	clawInstance.Shoot(shootDirection)

# Moved queue free into claw because of new functionality
func ExitState() -> void:
	player.finite_state_machine.sprite_flip_lock = false
	pivotPoint = Vector2.ZERO
	player.finite_state_machine.disable_gravity = false
