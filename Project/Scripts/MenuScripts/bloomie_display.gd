extends Control
@onready var bloomie: Sprite2D = $Bloomie

var bloomie_list = []

func _ready() -> void:
	visible = false
	
	bloomie_list.append(bloomie)
	if Global.chapterOneBloomies[0]:
		bloomie_list[0].modulate = "ffffffff"
	else:
		bloomie_list[0].modulate = "5c5c5c33"
	
	for i in Global.chapterOneBloomieCount-1:
		var new_bloomie = bloomie.duplicate()
		add_child(new_bloomie)
		new_bloomie.position.x = 8 + 16 * (i+1)
		bloomie_list.append(new_bloomie)
		
		
		if Global.chapterOneBloomies[i+1]:
			bloomie_list[i+1].modulate = "ffffffff"
		else:
			bloomie_list[i+1].modulate = "5c5c5c33"

func ResetBloomies() -> void:
	for i in bloomie_list.length():
		if Global.chapterOneBloomies[i]:
			bloomie_list[i].modulate = "ffffff33"
		else:
			bloomie_list[i].modulate = "5c5c5c33"

func AddBloomieCount(ID : int) -> void:
	bloomie_list[ID].modulate = "ffffffff"
