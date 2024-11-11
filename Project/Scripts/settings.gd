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

# Initial values
func _ready() -> void:
	is_fullscreen = true
	pixel_size = 2
