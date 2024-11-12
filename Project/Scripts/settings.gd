extends Node

const VIEWPORT_SIZE: Vector2i = Vector2i(640, 360)

## The pixel size of the game. [b]Cannot go below 0.[/b]
## Adjusting this will resize the window to compensate. 
## [i]If the window exceeds screen size, it automatically becomes fullscreen.[/i]
var pixel_size: int :
	get:
		return floor(get_window().size.x / VIEWPORT_SIZE.x)
	set(value):
		assert(value > 0, "Pixel size cannot be 0 or below")
		var window = get_window()
		
		window.size = VIEWPORT_SIZE * value
		if window.size.x >= DisplayServer.screen_get_size(window.current_screen).x:
			is_fullscreen = true
		window.move_to_center()

## The state of whether the window is fullscreen or not. 
## Adjusting this will change the window between the Windowed and Exclusive Fullscreen modes.
var is_fullscreen: bool :
	get:
		return (get_window().mode == Window.MODE_EXCLUSIVE_FULLSCREEN)
	set(value):
		var window = get_window()
		
		match (value):
			true:
				window.mode = Window.MODE_EXCLUSIVE_FULLSCREEN
			false:
				window.mode = Window.MODE_WINDOWED
				if VIEWPORT_SIZE.x * pixel_size >= DisplayServer.screen_get_size(window.current_screen).x:
					pixel_size = floor(DisplayServer.screen_get_size(window.current_screen).x / VIEWPORT_SIZE.x) - 1
				window.move_to_center()

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
	is_fullscreen = false
	pixel_size = 2
