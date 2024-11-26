extends Node

const VIEWPORT_SIZE: Vector2i = Vector2i(640, 360)

@onready var window : Window = get_window()
@onready var screen_size : Vector2i = DisplayServer.screen_get_size(get_window().current_screen)

## The pixel size of the game. [b]Cannot go below 0.[/b]
## Adjusting this will resize the window to compensate. 
## [i]If the window exceeds screen size, it automatically becomes fullscreen.[/i]
var pixel_size: int :
	get:
		return floor(window.size.x / VIEWPORT_SIZE.x)
	set(value):
		assert(value > 0, "Pixel size cannot be 0 or below")
		screen_size = DisplayServer.screen_get_size(get_window().current_screen)
		var new_window_size = VIEWPORT_SIZE * value
		if new_window_size.x >= screen_size.x:
			is_fullscreen = true
		else:
			is_fullscreen = false
		window.size = new_window_size
		window.move_to_center()

## The state of whether the window is fullscreen or not. 
## Adjusting this will change the window between the Windowed and Exclusive Fullscreen modes.
var is_fullscreen: bool :
	get:
		return (window.mode == Window.MODE_EXCLUSIVE_FULLSCREEN)
	set(value):
		screen_size = DisplayServer.screen_get_size(get_window().current_screen)
		match (value):
			true:
				window.mode = Window.MODE_EXCLUSIVE_FULLSCREEN
			false:
				window.mode = Window.MODE_WINDOWED
				if VIEWPORT_SIZE.x * pixel_size >= screen_size.x:
					pixel_size = floor(screen_size.x / VIEWPORT_SIZE.x) - 1

## The Master Volume. [b]Must be between 0 and 1.[/b]
## Adjusting this will change the volume of the whole game.
var master_volume: float :
	get:
		return db_to_linear(AudioServer.get_bus_volume_db(AudioManager.mixer_master))
	set(value):
		assert(value >= 0, "Master Volume must be between 0 and 1.")
		assert(value <= 1, "Master Volume must be between 0 and 1.")
		AudioServer.set_bus_volume_db(AudioManager.mixer_master, linear_to_db(value))

## The Music Volume. [b]Must be between 0 and 1.[/b]
## Adjusting this will change the volume of all music.
var music_volume: float :
	get:
		return db_to_linear(AudioServer.get_bus_volume_db(AudioManager.mixer_music))
	set(value):
		assert(value >= 0, "Music Volume must be between 0 and 1.")
		assert(value <= 1, "Music Volume must be between 0 and 1.")
		AudioServer.set_bus_volume_db(AudioManager.mixer_music, linear_to_db(value))

## The Sound FX Volume. [b]Must be between 0 and 1.[/b]
## Adjusting this will change the volume of all sound FX.
var sfx_volume: float :
	get:
		return db_to_linear(AudioServer.get_bus_volume_db(AudioManager.mixer_sfx))
	set(value):
		assert(value >= 0, "SFX Volume must be between 0 and 1.")
		assert(value <= 1, "SFX Volume must be between 0 and 1.")
		AudioServer.set_bus_volume_db(AudioManager.mixer_sfx, linear_to_db(value))

# Initial values
func _ready() -> void:
	process_mode = PROCESS_MODE_ALWAYS
	is_fullscreen = true
