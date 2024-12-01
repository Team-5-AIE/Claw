extends Node2D
var inRange : bool = true
var player
func _on_pickup_area_body_entered(body: Node2D) -> void:
	player = get_tree().root.get_node("/root/GameRoot2/Player")
	if player.is_on_floor():
		if body == player:
			PickUpSpear()
			inRange = true

func _process(delta: float) -> void:
	if player != null:
		if player.is_on_floor():
			PickUpSpear()
		
func PickUpSpear():
	var dialogueManager = get_tree().root.get_node("/root/GameRoot2/CanvasLayer/DialogueManager")
	print("picked up spear")
	player.spearCollected = true
	player.sprite_sheet.texture = player.PLAYER_SHEET
	dialogueManager.AddDialougeTextBox("Apologies to my elders...")
	dialogueManager.AddDialougeTextBox("...for stealing this treasure.")
	queue_free()
