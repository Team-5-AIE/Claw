class_name SWPlatformerCharacter
extends CharacterBody2D
# Signals
signal restartPlayer

# Node references
#Markers
@onready var spear_marker = $Marker2D
@onready var bloomieMarker2D = $BloomieMarker2D
@onready var dustMarker2D = $DustMarker2D
const RUN_DUST_PARTICLES = preload("res://Effects/run_dust_particles.tscn")
const SLIDE_DUST_PARTICLES = preload("res://Effects/slide_dust_particles.tscn")
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

# States
@onready var finite_state_machine = $FiniteStateMachine as FiniteStateMachine
@onready var state_idle = $FiniteStateMachine/StateIdle as StateIdle
@onready var state_move = $FiniteStateMachine/StateMove as StateMove
@onready var state_fall = $FiniteStateMachine/StateFall as StateFall
@onready var state_land = $FiniteStateMachine/StateLand as StateLand
@onready var state_jump = $FiniteStateMachine/StateJump as StateJump
@onready var state_spear = $FiniteStateMachine/StateSpear as StateSpear
@onready var state_crouch = $FiniteStateMachine/StateCrouch as StateCrouch
@onready var state_wall_climb = $FiniteStateMachine/StateWallClimb  as StateWallClimb
@onready var state_wall_jump = $FiniteStateMachine/StateWallJump as StateWallJump
@onready var state_wall_slide = $FiniteStateMachine/StateWallSlide as StateWallSlide
@onready var state_slide = $FiniteStateMachine/StateSlide as StateSlide

#Timers
@onready var coyote_jump_timer = $Timers/CoyoteJumpTimer
@onready var slide_timer = $Timers/SlideTimer
@onready var jump_buffer_timer = $Timers/JumpBufferTimer
@onready var wall_grab_stamina = $Timers/WallGrabStamina
@onready var spearCooldownTimer = $Timers/SpearCooldownTimer
@onready var snap_rope_timer: Timer = $Timers/SnapRopeTimer

#Visuals
@onready var animation_player = $AnimationPlayer
@onready var sprite_sheet = $SpriteSheet
@onready var legs_air = $LegsAir
@onready var legs_ground = $LegsGround

#Raycasts
@onready var raycast_slide_left = $RaycastSlideLeft
@onready var raycast_slide_right = $RaycastSlideRight
@onready var raycast_bottom_left = $RaycastBottomLeft
@onready var raycast_bottom_right = $RaycastBottomRight
@onready var raycast_top_left = $RaycastTopLeft
@onready var raycast_top_right = $RaycastTopRight
@onready var raycast_climb_left = $RaycastClimbLeft
@onready var raycast_climb_right = $RaycastClimbRight

#Hitboxes
@onready var hitbox = $Hitbox
@onready var slide_hitbox = $SlideHitbox

### Input
##Show console outputs of entering and exiting states
@export var debug_mode = true
@export var lockspear45direction : bool = false #NOTE: Remove later - keep for testing

### Enable|Disable Character states Settings
@export_group("Enable|Disable Character states/Jump")
## If On, allows the player to jump.
@export var jump_enabled : bool = true
@export var can_always_jump : bool = false
## How many pixels high the player should jump.
@export_range(0, 100, 1, "or_greater") var jump_height : float = 300.0 #TODO add limitation to other variables
var jump_available : bool = true
var jump_buffer : bool = false


@export_group("Enable|Disable Character states/Spear")
@export var throwSpearCooldown : float = 0.2


@export_group("Enable|Disable Character states/Slide")
## If On, allows the player to dash.
@export var slide_enabled : bool = true
## The speed at which to move the player during a slide.
@export var slide_speed : float = 250.0
## The time in seconds the player can slide for.
##Note: If the player is under a wall they will continue to slide until they are no longer under a wall.
@export var slide_time : float = 0.4
## The distance added to the jump when exiting Slide is enabled in pixels.
## How long after slide must the player wait until they are able to jump? Time in seconds.
@export var slide_jump_time_lockout : float = 0.1
@export var slide_friction : float = 1500.0


@export_group("Enable|Disable Character states/Crouch")
## If On, allows the player to crouch
@export var crouch_enabled : bool = true
@export var crouch_jump_height : float = 200
## If On, allows the player to move while crouched.
@export var crouch_walk_enabled : bool = true
## If On, allows the player to slide from crouch.
@export var slide_while_crouch_enabled : bool = true
## If On, allows the player to exit a slide early to crouch.
@export var cancel_slide_to_crouch_enabled : bool = true
## The speed the player will move if couching
@export var crouch_movespeed : float = 80.0


@export_group("Enable|Disable Character states/Wall")
@export var out_of_stamina_color : Color = Color(1.00, 0.15, 0.33, 1.00)
@export var low_stamina_flash_color : GradientTexture1D

@export_group("Enable|Disable Character states/Wall/WallClimb")
## If On, allows the player to climb on walls. Ledge climb will be enabled if this state is enabled.
@export var wall_climb_enabled : bool = true
## The speed the player can climb up a wall
@export var wall_climb_up_speed : float = 60.0
## The friction implementation of sliding down a wall. 1 = no friction
@export_range (0,1) var wall_climb_friction : float = 0.9
## If this value is 0 - no climb resistance. Otherwise it is the speed at which you slowly get pushed down while holding a wall.
@export var climb_resistance : float = 0
## If On, only allows players to climb walls while they have enough stamina.
@export var wall_grab_stamina_enabled : bool = true
## The amount of time in seconds the player can climb a wall before falling
@export var wall_grab_stamina_time : float = 6
##IMPORTANT!! Needs to be a number lower than Wall Grab Stamina Time.
## The amount of time in seconds the player will get a warning their stamina is running out.
@export var wall_grab_stamina_warning_time : float = 2


@export_group("Enable|Disable Character states/Wall/WallJump")
## If On, allows the player to jump off of walls.
@export var wall_jump_enabled : bool = true
## The speed the player will jump off a wall.
@export var wall_jump_speed : float = 200.0
## If On, there will be no limit to how many times the player can jump off a wall.
@export var always_allow_wall_jumps: bool = true
## The amount of times the player can wall jump before falling.
@export var max_wall_jumps: int = 2
var current_wall_jumps = max_wall_jumps
var wall_jump_available = true


@export_group("Enable|Disable Character states/Wall/WallSlide")
## If On, allows the player to slide down walls.
@export var wall_slide_enabled : bool = true
## The friction implementation of sliding down a wall. 1 = no friction
@export_range (0,1)  var wall_slide_friction : float = 0.9


### Advance Settings
@export_group("Advance Settings/GroundMovement")
@export var run_speed : float = 140.0
@export var acceleration : float = 950.0
@export var friction : float = 1500.0
@export var coyote_jump_time_delay : float = 0.1
@export_group("Advance Settings/AirMovement")
@export var gravity_speed : float = 850.0:
	set (value):
		gravity_speed = value
		current_gravity = gravity_speed
@export var max_gravity : float = 300.0:
	set (value):
		max_gravity = value
		current_max_gravity = max_gravity
@export var air_resistance : float = 200.0
@export var air_acceleration : float = 900.0

var current_gravity : float
var current_max_gravity : float

var input_axis : Vector2
var direction : int
var last_input_direction : Vector2 = Vector2(1,0)

var move_lock = false
var animation_end = false

#=================================Functions===================================================
func _ready() -> void:
	## Set variables based on exported variables.
	# Set Cooldown Timers.
	spearCooldownTimer.wait_time = throwSpearCooldown
	coyote_jump_timer.wait_time = coyote_jump_time_delay
	slide_timer.wait_time = slide_time
	wall_grab_stamina.wait_time = wall_grab_stamina_time
	
	# Set Default Gravity.
	current_gravity = gravity_speed
	current_max_gravity = max_gravity
	
	# Init default State as Idle.
	finite_state_machine.ChangeState(state_idle) # Set the player's state to free on start.
	
	#Set legs for spear throw as default false.
	legs_air.visible = false
	legs_ground.visible = false
	
func animation_finished(_anim_name):
	animation_end = true

func animation_started(_anim_name):
	animation_end = false


func _on_spike_area_body_entered(_body):
	restartPlayer.emit()

func instance_create(preloaded_scene, parent_node):
	var preloaded_scene_instance = preloaded_scene.instantiate()
	if parent_node:
		parent_node.add_child(preloaded_scene_instance)
	else:
		add_child(preloaded_scene_instance)
	return preloaded_scene_instance
	
func _on_room_area_ready():
	pass # Replace with function body.
