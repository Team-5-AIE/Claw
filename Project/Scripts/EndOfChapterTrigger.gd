@tool
extends Area2D

@export_file("*.tscn") var chapterEndScenePath : String

@onready var roomGlobals : Node2D = get_owner()

var player : SWPlatformerCharacter

func _on_room_init():
	player = roomGlobals.player

func _ready() -> void:
	if Engine.is_editor_hint():
		get_parent().set_editable_instance(self, true)

func _on_body_entered(body_: Node2D) -> void:
	if ! Engine.is_editor_hint():
		if body_ == player:
			roomGlobals.timeTracker.StopTimerAddToLastScore()
			
			FadeTransitions.Transition()
			await FadeTransitions.on_fade_in_finished
			
			get_tree().change_scene_to_file(chapterEndScenePath)
			
			await FadeTransitions.on_fade_out_finished
