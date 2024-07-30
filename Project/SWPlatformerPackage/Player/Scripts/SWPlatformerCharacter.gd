class_name SWPlatformerCharacter
extends CharacterBody2D

# Node references
@onready var coyote_jump_timer = $Timers/CoyoteJumpTimer
@onready var slide_timer = $Timers/SlideTimer
@onready var dash_timer = $Timers/DashTimer
@onready var jump_buffer_timer = $Timers/JumpBufferTimer
@onready var wall_grab_stamina = $Timers/WallGrabStamina
@onready var dash_cooldown = $Timers/DashCooldown

@onready var animation_player = $AnimationPlayer
@onready var sprite_sheet = $SpriteSheet
@onready var raycast_slide_left = $RaycastSlideLeft
@onready var raycast_slide_right = $RaycastSlideRight
@onready var raycast_bottom_left = $RaycastBottomLeft
@onready var raycast_bottom_right = $RaycastBottomRight
@onready var raycast_top_left = $RaycastTopLeft
@onready var raycast_top_right = $RaycastTopRight
@onready var raycast_climb_left = $RaycastClimbLeft
@onready var raycast_climb_right = $RaycastClimbRight

@onready var hitbox = $Hitbox
@onready var slide_hitbox = $SlideHitbox

### Input
##Show console outputs of entering and exiting states
@export var debug_mode = true
@export var out_of_stamina_color : Color = Color(1.00, 0.15, 0.33, 1.00)
@export var low_stamina_flash_color : GradientTexture1D

### Enable|Disable Character states Settings
@export_group("Enable|Disable Character states/Jump")
## If On, allows the player to jump.
@export var jump_enabled : bool = true
@export var can_always_jump : bool = false
## How many pixels high the player should jump.
@export_range(0, 100, 1, "or_greater") var jump_height : float = 300.0 #TODO add limitation to other variables
var jump_available : bool = true
@export_group("Enable|Disable Character states/DoubleJump")
## If On, allows the player to double jump.
@export var double_jump_enabled : bool = true
## How many pixels high the player should jump.
@export var double_jump_height : float = 300.0
var double_jump_available : bool = true
@export_group("Enable|Disable Character states/Dash")
## If On, allows the player to dash.
@export var dash_enabled : bool = true
## If On, only allows the player to dash while in the air.
@export var dash_only_in_air : bool = false
## How long the player must wait before recovering their dash.
@export var dash_cooldown_time : float = 0.1:
	set (value):
		dash_cooldown_time = value
		if dash_cooldown != null:
			dash_cooldown.wait_time = dash_cooldown_time
## The amount of times the player is allowed to dash before touching the ground.
@export var max_dashes : float = 1
## The speed at which the player will dash.
@export var dash_speed : float = 400.0
@export var dash_acceleration : float = 900
## The amount of time in seconds that the player stays in the dash for.
@export var dash_time : float = 0.3:
	set (value):
		dash_time = value
		if dash_timer != null:
			dash_timer.wait_time = dash_time
##IMPORTANT!! Needs to be a number lower than Dash Time.
## How long after dash must the player wait until they are able to jump? Time in seconds.
@export var dash_jump_time_lockout : float = 0.1
## If On, the player can reset their dash if they jump within a certian time(Dash Grounded Reset Time) after inital dash.
@export var wave_dash_enabled : bool = true
## The amount of time in seconds the player has after dashing to reset their dash by jumping.
@export var wave_dash_enabled_time_window : float = 0.1
## If On, enables additional gravity when leaving the dash state. Only consider using this if the dash feels floaty when exiting.
@export var exit_dash_forced_gravity_enabled : bool = true
## the gravity to added to Y velocity when exiting dash state.
@export var exit_dash_forced_gravity_multipler : float = 5

var current_dashes = max_dashes
var dash_available = true
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
@export_group("Enable|Disable Character states/Crouch")
## If On, allows the player to crouch
@export var crouch_enabled : bool = true
## If On, allows the player to move while crouched.
@export var crouch_walk_enabled : bool = true
## If On, allows the player to slide from crouch.
@export var slide_while_crouch_enabled : bool = true
## If On, allows the player to exit a slide early to crouch.
@export var cancel_slide_to_crouch_enabled : bool = true
## The speed the player will move if couching
@export var crouch_movespeed : float = 80.0
@export_group("Enable|Disable Character states/Glide")
## If On, allows the player to glide
@export var glide_enabled : bool = true
## The speed the player will move while gliding
@export var glide_speed : float = 50.0
@export var glide_acceleration : float = 300
@export var glide_resistance : float = 200
## This affects the speed the player will move down while gliding.
@export var glide_gravity : float = 180.0
## This affects the max speed the player will move down while gliding.
@export var max_glide_gravity : float = 25.0
@export_group("Enable|Disable Character states/Wall")
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
@export_group("Enable|Disable Character states/LedgeClimb")
## If On, allows the player to pull themselves up when hitting the edge of a collision.
@export var ledge_climb_enabled : bool = true

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

# States
@onready var finite_state_machine = null
@onready var state_idle = null
@onready var state_move = null
@onready var state_fall = null
@onready var state_jump = null
@onready var state_double_jump = null
@onready var state_land = null
@onready var state_slide = null
@onready var state_dash = null
@onready var state_crouch = null
@onready var state_crouch_move = null
@onready var state_glide = null
@onready var state_wall_slide = null
@onready var state_wall_jump = null
@onready var state_wall_climb = null
@onready var state_ledge_climb = null
@onready var state_claw = $FiniteStateMachine/StateClaw as StateClaw
@onready var claw_marker = $Marker2D

var move_lock = false
var input_axis : Vector2
var direction : int
var animation_end = false
var last_input_direction : Vector2 = Vector2(1,0)
var current_gravity : float
var current_max_gravity : float
var jump_buffer : bool = false

func _ready() -> void:
	coyote_jump_timer.wait_time = coyote_jump_time_delay
	slide_timer.wait_time = slide_time
	dash_timer.wait_time = dash_time
	wall_grab_stamina.wait_time = wall_grab_stamina_time
	dash_cooldown.wait_time = dash_cooldown_time
	if !crouch_enabled:
		crouch_walk_enabled = false
		slide_while_crouch_enabled = false
		cancel_slide_to_crouch_enabled = false
	current_gravity = gravity_speed
	current_max_gravity = max_gravity
	create_state_nodes()
	finite_state_machine.ChangeState(state_idle) # Set the player's state to free on start.
func animation_finished(_anim_name):
	animation_end = true
	

func animation_started(_anim_name):
	animation_end = false

func create_state_nodes():
	finite_state_machine = $FiniteStateMachine as FiniteStateMachine
	state_idle = $FiniteStateMachine/StateIdle as StateIdle
	state_move = $FiniteStateMachine/StateMove as StateMove
	state_fall = $FiniteStateMachine/StateFall as StateFall
	state_land = $FiniteStateMachine/StateLand as StateLand
	if jump_enabled: 
		var stateNode = StateJump.new()
		stateNode.name = "StateJump"
		finite_state_machine.add_child(stateNode)
		state_jump = $FiniteStateMachine/StateJump as StateJump
		
	if double_jump_enabled: 
		var stateNode = StateDoubleJump.new()
		stateNode.name = "StateDoubleJump"
		finite_state_machine.add_child(stateNode)
		state_double_jump = $FiniteStateMachine/StateDoubleJump as StateDoubleJump
	
	if slide_enabled: 
		var stateNode = StateSlide.new()
		stateNode.name = "StateSlide"
		finite_state_machine.add_child(stateNode)
		state_slide = $FiniteStateMachine/StateSlide as StateSlide
	
	if dash_enabled: 
		var stateNode = StateDash.new()
		stateNode.name = "StateDash"
		finite_state_machine.add_child(stateNode)
		state_dash = $FiniteStateMachine/StateDash as StateDash
	
	if crouch_enabled: 
		var stateNode = StateCrouch.new()
		stateNode.name = "StateCrouch"
		finite_state_machine.add_child(stateNode)
		state_crouch = $FiniteStateMachine/StateCrouch as StateCrouch
	
	if crouch_walk_enabled: 
		var stateNode = StateCrouchMove.new()
		stateNode.name = "StateCrouchMove"
		finite_state_machine.add_child(stateNode)
		state_crouch_move = $FiniteStateMachine/StateCrouchMove as StateCrouchMove
	
	if glide_enabled: 
		var stateNode = StateGlide.new()
		stateNode.name = "StateGlide"
		finite_state_machine.add_child(stateNode)
		state_glide = $FiniteStateMachine/StateGlide as StateGlide
	
	if wall_slide_enabled: 
		var stateNode = StateWallSlide.new()
		stateNode.name = "StateWallSlide"
		finite_state_machine.add_child(stateNode)
		state_wall_slide = $FiniteStateMachine/StateWallSlide as StateWallSlide
	
	if wall_jump_enabled: 
		var stateNode = StateWallJump.new()
		stateNode.name = "StateWallJump"
		finite_state_machine.add_child(stateNode)
		state_wall_jump = $FiniteStateMachine/StateWallJump as StateWallJump
	
	if wall_climb_enabled: 
		ledge_climb_enabled = true
		var stateNode = StateWallClimb.new()
		stateNode.name = "StateWallClimb"
		finite_state_machine.add_child(stateNode)
		state_wall_climb = $FiniteStateMachine/StateWallClimb as StateWallClimb
	
	if ledge_climb_enabled: 
		var stateNode = StateLedgeClimb.new()
		stateNode.name = "StateLedgeClimb"
		finite_state_machine.add_child(stateNode)
		state_ledge_climb = $FiniteStateMachine/StateLedgeClimb 

