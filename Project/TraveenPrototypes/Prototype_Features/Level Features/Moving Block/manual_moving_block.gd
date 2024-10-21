extends MovingBlock

@export var active_on_startup : bool
@export var loopable: bool
@export var linked_activator: LevelActivator
## When the block becomes inactive, choose whether it applies immediately or when animation ends
@export_enum("Immediate", "End of Animation") var inactive_trigger_mode: int
@export_group("Deactivate Animation")
## When the block becomes inactive, queue the deactivate animation
@export var use_deactivate_animation: bool
@export var deactivate_animation_name: String

var active: bool 


# Override with manual block functionality and connecting with linked_activator 
func _setup_moving_block() -> void:
	# Guard to force linking to activator
	assert(linked_activator != null, "No linked activator on Moving Block: " + str(self))
	linked_activator.activated.connect(_on_flag_activated)
	linked_activator.deactivated.connect(_on_flag_deactivated)
	
	active = active_on_startup
	animation_player.get_animation(animation_name).set_loop_mode(set_loop_behaviour(anim_loop_mode, loopable))
	if active_on_startup:
		animation_player.play(animation_name)

# Functions connecting the flag signals to the block
func _on_flag_activated(flag_ID: int) -> void:
	change_block_activity(true)
func _on_flag_deactivated(flag_ID: int) -> void:
	change_block_activity(false)

# Functions to detect if animation has ended
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	_manage_animation(anim_name)
func _process(delta) -> void:
	if animation_player.is_playing():
		if animation_player.current_animation_position == animation_player.current_animation_length:
			if not active and animation_player.current_animation == animation_name:
				_manage_animation(animation_player.current_animation)

# Manages the looping and animation switching functionality
func _manage_animation(anim_name) -> void:
	if active:
		animation_player.play(animation_name)
	elif anim_name == animation_name and deactivate_animation_name:
		animation_player.play(deactivate_animation_name)
	else:
		animation_player.stop()

# Change active state of the block. 
# If active: Play main animation
# If inactive and the inactive trigger mode is set to immediate: Process the animation inactivity 
func change_block_activity(active_state: bool) -> void:
	active = active_state
	if active_state == true:
		animation_player.play(animation_name)
	elif inactive_trigger_mode == 0:
			end_activity()

# Pause current animation
# If use deactivate animation is true, stop animation and play the inactive animation
func end_activity() -> void:
	if use_deactivate_animation == false:
		animation_player.pause()
	else:
		animation_player.stop()
		animation_player.play(deactivate_animation_name)


func _physics_process(delta: float) -> void:
	if $MovingBlockVisual/Label != null:
		match(active):
			true:
				$MovingBlockVisual/Label.text = "ON"
			false:
				$MovingBlockVisual/Label.text = "OFF"
