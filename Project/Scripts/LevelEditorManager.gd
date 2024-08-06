extends Node2D

@export var m_tilePalette : TileMap

func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			var id = m_tilePalette.get_cell_atlas_coords(0, m_tilePalette.local_to_map(event.position))
			print_debug(id)
