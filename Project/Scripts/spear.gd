class_name Spear
extends CharacterBody2D
@onready var spear: Sprite2D = $Spear


@onready var direction : Vector2
@onready var speed : float = 5
var player : CharacterBody2D
var tip : Vector2 = Vector2(0,0)

@export var SPEED : float = 20
@export var maxDistance = 150
var extending : bool = false
var hooked : bool = false
var retracted : bool = false
var distanceToPlayer : float = 0
var ropeLength : float = 0
var pullReleased = false
var flipped = false
var ropeSnapTimerStarted = false
var timerStarted = false
var audio_stream_player: AudioStreamPlayer
const JUMP1 = preload("res://Sounds/Effects/jump (2).wav")
const JUMP2 = preload("res://Sounds/Effects/jump (3).wav")


func _draw():
	var spearToPlayer = player.spear_marker.global_position - global_position
	draw_line(Vector2.ZERO, spearToPlayer,Color.WHITE,1,false)
	#draw_line(Vector2.ZERO, - spearToPlayer.normalized()*50, Color.DARK_ORCHID)

func _process(_delta):
	queue_redraw()
	if extending:
		spear.rotation = player.get_angle_to(tip) - deg_to_rad(-45)

func _physics_process(_delta):
	if Retract(): return
	#===Pull
	if Input.is_action_just_pressed("SpearPull") && player.is_on_floor():
		if player.state_spear.spearInstance != null:
			print("pull")
			player.state_spear.audio_stream_player.stream = player.state_spear.PULLJUMP
			player.state_spear.audio_stream_player.play()
			player.state_spear.spearInstance.pullReleased = true
			#if spearInstance.ropeLength > 16:
			#	spearInstance.ropeLength -= delta * 150
			player.velocity *= (1.0 - player.state_spear.pullJumpStopFraction)
			
			var spearToPlayer = player.spear_marker.global_position - player.state_spear.spearInstance.global_position
			player.velocity += -spearToPlayer.normalized() * player.state_spear.pullJumpStrength
			return
		else:
			print("spear instance does not exists - tried to pull")
	
	
	#===
	if extending:
		var collision = move_and_collide(direction * SPEED)
		if collision:
			remove_collision_exception_with(self)
			print("A hook thing just happened!")
			ropeLength = player.spear_marker.global_position.distance_to(global_position)
			hooked = true
			extending = false
			
	if hooked:
		if player.finite_state_machine.state == player.state_fall:
			player.finite_state_machine.ChangeState(player.state_spear)
		if player.finite_state_machine.state == player.state_spear && player.is_on_floor():
			player.finite_state_machine.ChangeState(player.state_idle)
	tip = global_position
	#Auto release the hook if you're grounded
	if player.is_on_floor() && !extending && !ropeSnapTimerStarted:
		player.snap_rope_timer.start()
		ropeSnapTimerStarted = true
	if !player.is_on_floor():
		ropeSnapTimerStarted = false
	
	if player.snap_rope_timer.time_left == 0.00 && ropeSnapTimerStarted:
		Release()
		ropeSnapTimerStarted = false
		return
	
	distanceToPlayer = global_position.distance_to(player.spear_marker.global_position)
	if distanceToPlayer > maxDistance:
		Release()
		return
	if pullReleased:
		Release()
		return
	if Input.is_action_just_released("Spear") && !extending:
		Release()
		return
	
func Shoot(dir : Vector2) -> void:
	direction = dir.normalized()
	extending = true
	tip = self.global_position

func Release() -> void:
	#print("Release")
	if player.is_on_floor():
		player.finite_state_machine.ChangeState(player.state_idle)
	else:
		player.finite_state_machine.ChangeState(player.state_fall)
	retracted = true

func JumpRelease() -> void: #NOTE: Not used
	#print("Jump Release")
	var randSound = randi_range(0,1)
	match randSound:
		0: audio_stream_player.stream = JUMP1
		1: audio_stream_player.stream = JUMP2
	audio_stream_player.play()
	if player.is_on_floor():
		player.state_fall.jumpedFromSpear = true
		player.finite_state_machine.ChangeState(player.state_idle)
	else:
		player.state_fall.jumpedFromSpear = true
		player.finite_state_machine.ChangeState(player.state_fall)
	retracted = true

func Retract() -> bool:
	if retracted:
		#print("Retract")
		var spearToPlayer = player.spear_marker.global_position - global_position
		global_position += spearToPlayer.normalized() * SPEED
		var timer = $Destroy
		if !timerStarted:
			timerStarted = true
			timer.start()
		return true
	return false

func _on_auto_grapple_area_body_entered(_body: Node2D):
	print("AutoGrapple point grabbed")
	if !retracted:
		player.state_spear.AutoGrapple(global_position)


func _on_destroy_timeout() -> void:
	if retracted:
		print("destroy spear")
		extending = false
		retracted = false
		player.sprite_sheet.texture = player.PLAYER_SHEET
		player.state_spear.spearInstance = null
		queue_free()
		return
