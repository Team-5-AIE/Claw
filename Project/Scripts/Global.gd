extends Node

var totalBloomiesCollected : int = 0
var chapterOneBloomies : Array[bool]
var chapterOneBloomieCount = 5
# Called when the node enters the scene tree for the first time.
func _ready():
	chapterOneBloomies.resize(chapterOneBloomieCount)
	chapterOneBloomies.fill(false)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
