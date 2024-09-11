extends Node2D
@export var strText : String = "text"

func _ready() -> void:
	var dialogueManager = get_tree().root.get_node("/root/GameRoot2/CanvasLayer/DialogueManager")
	dialogueManager.AddDialougeTextBox(strText)
	queue_free()
