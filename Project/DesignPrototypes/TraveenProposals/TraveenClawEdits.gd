class_name TraveenClawEdits
extends Claw

@export var pullSpeedMultiplier: float = 2
@export var retractedClawForceWhilePulled: float = 300

func _physics_process(delta):
	if extending :
		if move_and_collide(direction * SPEED):
			player.state_claw.SetStartPosition(global_position,player.global_position)
			hooked = true
			extending = false
	#NOTE: UNCOMMENT
	if distanceToPlayer <= 16 && hooked:
		Release()
		self.queue_free()
		return
	if distanceToPlayer > maxDistance:
		Release()
	if Input.is_action_just_released("Claw") && !extending:
		Release()
	
	#if distanceToPlayer <= 16 && retracted:
		#if Input.is_action_pressed("ClawPull"):
			## Add acceleration to player in direction of claw's movement
			#player.velocity += direction * retractedClawForceWhilePulled
			#pass
		#self.queue_free()
		#return
	# Retract claw at either regular speed or at fast speed
	if retracted:
		var returnVelocity: Vector2
		
		direction = (player.global_position - tip).normalized()
		if Input.is_action_pressed("ClawPull"):
			returnVelocity = (direction * SPEED * pullSpeedMultiplier)
		else:
			returnVelocity = (direction * SPEED)
		
		if move_and_collide(returnVelocity):
			if Input.is_action_pressed("ClawPull"):
				# Add acceleration to player in direction of claw's movement
				player.velocity += direction * retractedClawForceWhilePulled
				pass
			self.queue_free()
			return
	
	tip = global_position

func Release() -> void:
	retracted = true
	hooked = false
	set_collision_mask_value(2, false)
	set_collision_mask_value(1, true)
	if player.is_on_floor():
		player.finite_state_machine.ChangeState(player.state_idle)
	else:
		player.finite_state_machine.ChangeState(player.state_fall)
