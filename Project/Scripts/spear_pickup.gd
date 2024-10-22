extends Node2D


func _on_pickup_area_body_entered(body: Node2D) -> void:
	var player = get_tree().root.get_node("/root/GameRoot2/Player")
	var dialogueManager = get_tree().root.get_node("/root/GameRoot2/CanvasLayer/DialogueManager")
	if body == player:
		print("picked up spear")
		player.spearCollected = true
		player.sprite_sheet.texture = player.PLAYER_SHEET
		dialogueManager.AddDialougeTextBox("Spear collected text here.")
		queue_free()
