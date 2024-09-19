extends CanvasLayer

signal on_fade_in_finished
signal on_fade_out_finished

@export_range(1, 16) var grid_slide_in_speed_scale: int = 6
@export_enum("Horizontal", "Vertical", "Diagonal Left", "Diagonal Right") var grid_slide_in_direction: int = 0
@export_range(1, 16) var grid_slide_out_speed_scale: int = 6
@export_enum("Horizontal", "Vertical", "Diagonal Left", "Diagonal Right") var grid_slide_out_direction: int = 0
var grid_slide_velocity: Vector2
@onready var grid_slide_start: TextureRect = $GridSlide/SlideStart
@onready var grid_slide_end: TextureRect = $GridSlide/SlideEnd

@onready var color_rect: ColorRect = $ColorRect
@onready var animation_player: AnimationPlayer = $AnimationPlayer

@export var lockPlayer = false
var restart = false
func _ready():
	set_process_mode(ProcessMode.PROCESS_MODE_ALWAYS)
	
	color_rect.visible = false
	animation_player.animation_finished.connect(_on_animation_finished)
	lockPlayer = false
	
	grid_slide_start.visible = false
	grid_slide_end.visible = false

func _on_animation_finished(anim_name):
	if anim_name == "FadeIn":
		on_fade_in_finished.emit()
		animation_player.play("FadeOut")
	elif anim_name == "FadeOut":
		on_fade_out_finished.emit()
		color_rect.visible = false
		
	#Restart
	elif anim_name == "FadeInRestart":
		on_fade_in_finished.emit()
		restart = false
		animation_player.play("FadeOutRestart")
	elif anim_name == "FadeOutRestart":
		on_fade_out_finished.emit()
		color_rect.visible = false


func Transition():
	lockPlayer = true
	color_rect.visible = true
	animation_player.play("FadeIn")

func TransitionRestart():
	StartSlide(grid_slide_in_direction, grid_slide_out_direction)

func StartSlide(slide_in_direction: int, slide_out_direction: int):
	var grid_slide_duration_frames: int = 0
	var slide_half_frames: int = 0
	
	# Setting up transition
	lockPlayer = true
	restart = true
	color_rect.visible = true
	
	SetUpSlideGrids(slide_in_direction)
	grid_slide_start.visible = true
	grid_slide_end.visible = true
	
	# Sliding in
	grid_slide_duration_frames = GridSlideDuration(slide_in_direction, grid_slide_in_speed_scale)
	slide_half_frames = grid_slide_duration_frames
	
	while slide_half_frames > 0:
		grid_slide_start.position += grid_slide_velocity
		grid_slide_end.position -= grid_slide_velocity
		color_rect.modulate = lerp(Color.BLACK, Color.TRANSPARENT, float(slide_half_frames)/float(grid_slide_duration_frames))
		await Engine.get_main_loop().process_frame
		slide_half_frames -= 1
	
	# End of slide in
	on_fade_in_finished.emit()
	restart = false
	
	grid_slide_start.position = Vector2.ZERO
	grid_slide_end.position = Vector2.ZERO
	color_rect.modulate = Color.BLACK
	
	# Sliding out
	grid_slide_duration_frames = GridSlideDuration(slide_out_direction, grid_slide_out_speed_scale)
	slide_half_frames = grid_slide_duration_frames
	
	while slide_half_frames > 0:
		grid_slide_start.position += grid_slide_velocity
		grid_slide_end.position -= grid_slide_velocity
		color_rect.modulate = lerp(Color.TRANSPARENT, Color.BLACK, float(slide_half_frames)/float(grid_slide_duration_frames))
		await Engine.get_main_loop().process_frame
		slide_half_frames -= 1
	
	# End of slide out
	on_fade_out_finished.emit()
	lockPlayer = false
	color_rect.visible = false
	grid_slide_start.visible = false
	grid_slide_end.visible = false

func SetUpSlideGrids(direction_mode: int) -> void:
	
	grid_slide_start.position = Vector2.ZERO
	grid_slide_end.position = Vector2.ZERO
	
	match direction_mode:
		1: # Vertical
			grid_slide_start.position.y = -grid_slide_start.size.y
			grid_slide_end.position.y = grid_slide_start.size.y
		2: # Diagonal Left
			grid_slide_start.position = -grid_slide_start.size
			grid_slide_end.position = grid_slide_start.size
		3: # Diagonal Right
			grid_slide_start.position.x = -grid_slide_start.size.x
			grid_slide_start.position.y = grid_slide_start.size.y
			grid_slide_end.position.x = grid_slide_start.size.x
			grid_slide_end.position.y = -grid_slide_start.size.y
		_: # Horizontal
			grid_slide_start.position.x = -grid_slide_start.size.x
			grid_slide_end.position.x = grid_slide_start.size.x

func GridSlideDuration(direction_mode: int, slide_speed_scale: int) -> int:
	var frame_count: float
	
	match direction_mode:
		1: # Vertical
			grid_slide_velocity = Vector2(0, 2 * slide_speed_scale)
			frame_count = grid_slide_start.size.y/(2 * slide_speed_scale)
		2: # Diagonal Left
			grid_slide_velocity = Vector2(4 * slide_speed_scale, 2 * slide_speed_scale)
			frame_count = grid_slide_start.size.y/(2 * slide_speed_scale)
		3: # Diagonal Right
			grid_slide_velocity = Vector2(4 * slide_speed_scale, -2 * slide_speed_scale)
			frame_count = grid_slide_start.size.y/(2 * slide_speed_scale)
		_: # Horizontal
			grid_slide_velocity = Vector2(4 * slide_speed_scale, 0)
			frame_count = grid_slide_start.size.x/(4 * slide_speed_scale)
	
	return roundi(frame_count)
