extends PanelContainer

@export var fullscreen_toggle : CheckButton
@export var pixel_size_buttons : Array[Button]
@export_group("Volumes")
@export var master_num : LineEdit
@export var master_slider : HSlider
@export var music_num : LineEdit
@export var music_slider : HSlider
@export var sfx_num : LineEdit
@export var sfx_slider : HSlider
@export_group("Slider")
@export var change_per_second = 20
@export var change_interval: float

var joypad_timer: float = 0

var joypad_cooldown: float :
	get:
		return change_interval * get_physics_process_delta_time()

var is_active : bool :
	get:
		return visible
	set(state):
		visible = state
		if state == true:
			read_visual_settings()
			read_audio_settings()

# Called when the node enters the scene tree for the first time.
func _enter_tree() -> void:
	initialise_pixel_size_buttons()

# Initialise the pixel size buttons. Hide pixel size buttons that exceed screen size
func initialise_pixel_size_buttons() -> void:
	var max_pixel_size: int = floor(Settings.screen_size.x / Settings.VIEWPORT_SIZE.x)
	
	for i in range(pixel_size_buttons.size()):
		if i+1 > max_pixel_size: # Make invisible when above screen size
			pixel_size_buttons[i].visible = false
			pixel_size_buttons[i].disabled = true
			pixel_size_buttons[i].focus_mode = Control.FOCUS_NONE
		else: # Make visible when under screen size
			pixel_size_buttons[i].visible = true
			pixel_size_buttons[i].focus_mode = Control.FOCUS_ALL
		
		if i+1 == max_pixel_size: # Connect final pixel size button with first button
			pixel_size_buttons[i].focus_neighbor_right = pixel_size_buttons[i].get_path_to(pixel_size_buttons[0])
			pixel_size_buttons[0].focus_neighbor_left = pixel_size_buttons[0].get_path_to(pixel_size_buttons[i])
	
	# If absolute last button is visible, connect to first button 
	if pixel_size_buttons[-1].visible:
		pixel_size_buttons[-1].focus_neighbor_right = pixel_size_buttons[-1].get_path_to(pixel_size_buttons[0])
		pixel_size_buttons[0].focus_neighbor_left = pixel_size_buttons[0].get_path_to(pixel_size_buttons[-1])

# Read the visual settings and apply to each of the appropriate options elements
func read_visual_settings() -> void:
	await get_tree().process_frame
	
	# Fullscreen toggle button
	fullscreen_toggle.set_pressed_no_signal(Settings.is_fullscreen)
	
	# Pixel Size Buttons
	for i in range(pixel_size_buttons.size()):
		if pixel_size_buttons[i].visible:
			if i+1 == Settings.pixel_size: # Press button and disable it
				pixel_size_buttons[i].set_pressed_no_signal(true)
				pixel_size_buttons[i].disabled = true
			else: # Unpress all other buttons
				pixel_size_buttons[i].set_pressed_no_signal(false)
				pixel_size_buttons[i].disabled = false

# Read the visual settings and apply to each of the appropriate options elements
func read_audio_settings() -> void:
	master_num.text = str(int(Settings.master_volume * 100))
	master_slider.value = Settings.master_volume * 100
	
	music_num.text = str(int(Settings.music_volume * 100))
	music_slider.value = Settings.music_volume * 100
	
	sfx_num.text = str(int(Settings.sfx_volume * 100))
	sfx_slider.value = Settings.sfx_volume * 100


# ===== Applying Settings =====

# Enable slider usage with keys
func _physics_process(delta: float) -> void:
	if joypad_timer <= 0:
		var current_focus = get_viewport().gui_get_focus_owner()
		# Check if current focus is a slider
		if current_focus != null && current_focus is HSlider:
			# Check if aim direction is not 0
			var aim_direction = get_joy_vector().x
			if aim_direction != 0:
				joypad_timer = joypad_cooldown
				current_focus.value += aim_direction * change_per_second * joypad_cooldown
	else:
		joypad_timer -= delta

# Fullscreen toggle
func _on_button_fullscreen_toggled(toggled_on: bool) -> void:
	Settings.is_fullscreen = toggled_on
	read_visual_settings()

# Pixel size buttons
func _on_button_size_pressed(new_pixel_size: int) -> void:
	Settings.pixel_size = new_pixel_size
	read_visual_settings()

# Master volume slider
func _on_volume_master_slider_value_changed(value: float) -> void:
	Settings.master_volume = value / 100
	master_num.text = str(int(value))
	master_slider.value = value

# Music volume slider
func _on_volume_music_slider_value_changed(value: float) -> void:
	Settings.music_volume = value / 100
	music_num.text = str(int(value))
	music_slider.value = value

# SFX volume slider
func _on_volume_sfx_slider_value_changed(value: float) -> void:
	Settings.sfx_volume = value / 100
	sfx_num.text = str(int(value))
	sfx_slider.value = value

# Master and SFX slider: Play Bloomie sound when finishing using the slider
func _on_volume_slider_drag_ended(value_changed: bool) -> void:
	AudioManager.play_menu_sound(AudioManager.COLLECT_BLOOMIE, 0)


# ===== Other =====

func get_joy_vector() -> Vector2:
	var joyX: float
	var joyY: float
	
	#if Input.is_action_pressed("Aim Down"):
		#joyY = joyPadSpeed
	#elif Input.is_action_pressed("Aim Up"):
		#joyY = -joyPadSpeed
	#if Input.is_action_pressed("Aim Right"):
		#joyX = joyPadSpeed
	#elif Input.is_action_pressed("Aim Left"):
		#joyX = -joyPadSpeed
		
	var leftJoyAxis = Input.get_vector("Left", "Right", "Up", "Down")
	var rightJoyAxis = Input.get_vector("Aim Left", "Aim Right", "Aim Up", "Aim Down")
	
	if rightJoyAxis != Vector2.ZERO:
		joyX = rightJoyAxis.x
		joyY = rightJoyAxis.y
	elif leftJoyAxis != Vector2.ZERO:
		joyX = leftJoyAxis.x
		joyY = leftJoyAxis.y
	else:
		joyX = 0
		joyY = 0
	
	return Vector2(joyX, joyY)
