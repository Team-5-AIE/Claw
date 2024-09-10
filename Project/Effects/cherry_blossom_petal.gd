extends GPUParticles2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
		visible = true
		var canvas = get_canvas_transform()
		var top_left = -canvas.origin / canvas.get_scale() 
		#TODO: needs to be room size not canvas size
		#Need to talk with Emma.
		var size = get_viewport_rect().size / canvas.get_scale()
		global_position.x = top_left.x + size.x/2
		global_position.y = top_left.y - 50
		get_process_material().set_emission_box_extents(Vector3(size.x,-50,1))
