extends Control
@onready var bloomie_1: Sprite2D = $Bloomie1
@onready var bloomie_2: Sprite2D = $Bloomie2
@onready var bloomie_3: Sprite2D = $Bloomie3
@onready var bloomie_4: Sprite2D = $Bloomie4
@onready var bloomie_5: Sprite2D = $Bloomie5
@onready var bloomie_6: Sprite2D = $Bloomie6

func _ready() -> void:
	visible = false

func AddBloomieCount(ID : int) -> void:
	match ID:
		0: bloomie_1.modulate = "ffffffff"
		1: bloomie_2.modulate = "ffffffff"
		2: bloomie_3.modulate = "ffffffff"
		3: bloomie_4.modulate = "ffffffff"
		4: bloomie_5.modulate = "ffffffff"
		5: bloomie_6.modulate = "ffffffff"
