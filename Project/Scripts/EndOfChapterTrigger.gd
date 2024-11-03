@tool
extends Area2D

@export_file("*.tscn") var chapterEndScenePath : String

@onready var roomGlobals : Node2D = get_owner()
var endChapter = false
var player : SWPlatformerCharacter
var dialogueManager
func _on_room_init():
	player = roomGlobals.player

func _ready() -> void:
	if Engine.is_editor_hint():
		get_parent().set_editable_instance(self, true)

func _process(delta: float) -> void:
	if endChapter && dialogueManager != null:
		if dialogueManager.textQueue.is_empty():
			endChapter = false
			FadeTransitions.Transition()
			await FadeTransitions.on_fade_in_finished
			var bloomieDisplay = get_tree().root.get_node("/root/GameRoot2/CanvasLayer/BloomieDisplay")
			bloomieDisplay.visible = false
			get_tree().change_scene_to_file(chapterEndScenePath)
			await FadeTransitions.on_fade_out_finished
			if LevelFlags.chapterFlags.size() > 0: LevelFlags.chapterFlags.resize(0)

func _on_body_entered(body_: Node2D) -> void:
	if ! Engine.is_editor_hint():
		if body_ == player:
			roomGlobals.pauseMenu.inGame = false
			roomGlobals.timeTracker.StopTimerAddToLastScore()
			
			FadeTransitions.lockPlayer = true
			
			dialogueManager = get_tree().root.get_node("/root/GameRoot2/CanvasLayer/DialogueManager")
			dialogueManager.AddDialougeTextBox("Izumo..")
			dialogueManager.AddDialougeTextBox("I'll save you.")
			endChapter = true
