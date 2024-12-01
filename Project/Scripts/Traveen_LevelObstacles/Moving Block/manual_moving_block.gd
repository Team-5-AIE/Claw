extends MovingBlock

@export var loopable: bool
@export var linked_activator: LevelActivator
@export var invert_active_states : bool = false
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
	
	animation_player.get_animation(animation_name).set_loop_mode(Animation.LOOP_NONE)
	
	change_block_activity(linked_activator.is_active)

# Functions connecting the flag signals to the block
func _on_flag_activated(_flagID: int) -> void:
	change_block_activity(true)
func _on_flag_deactivated(_flagID: int) -> void:
	change_block_activity(false)

# Functions to detect if animation has ended
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	_manage_animation(anim_name)
func _process(_delta) -> void:
	if animation_player.is_playing():
		if animation_player.current_animation_position == 0:
			if not active and animation_player.current_animation == animation_name:
				_manage_animation(animation_player.current_animation)

# Manages the looping and animation switching functionality
func _manage_animation(anim_name) -> void:
	if active:
		if loopable:
			animation_player.play(animation_name)
		else:
			animation_player.stop(true)
	elif anim_name == animation_name and deactivate_animation_name:
		animation_player.play(deactivate_animation_name)
	else:
		animation_player.stop(true)

# Change active state of the block. 
# If active: Play main animation
# If inactive and the inactive trigger mode is set to immediate: Process the animation inactivity 
func change_block_activity(active_state: bool) -> void:
	match (invert_active_states):
		true:
			active = !active_state
		false:
			active = active_state
	if active == true:
		animation_player.play(animation_name)
		AudioManager.play_modulated_game_sound(AudioManager.DOOR3, -18)
	elif inactive_trigger_mode == 0:
			end_activity()

# Pause current animation
# If use deactivate animation is true, stop animation and play the inactive animation
func end_activity() -> void:
	if use_deactivate_animation == false:
		animation_player.pause()
	else:
		animation_player.stop(true)
		animation_player.play(deactivate_animation_name)
