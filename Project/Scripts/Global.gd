extends Node

var totalBloomiesCollected : int = 0
var chapterOneBloomies : Array[bool]
var chapterOneBloomiesThisSession : Array[bool]
var chapterOneBloomieCount = 9

var crosshair: Crosshair

#This holds all the data of score entry
#first entry is the latest one.
var lastScore = ["NAME","0:14",14]#[Name, Score as string, time]

#This holds all the data of score entry
#First entry is the fastest time - accending order. 
var highscores = [] #[Name, Score as string, time]

var json = JSON.new()
var path = "res://save_data.json"

var data = {}
#Save data stuff
func WriteToSave(content):
	var file = FileAccess.open(path,FileAccess.WRITE)
	file.store_string(JSON.stringify(content))
	file.close()
	file = null

func ReadSave():
	var file = FileAccess.open(path,FileAccess.READ)
	var content = JSON.parse_string(file.get_as_text())
	return content

func CreateDefaultSave():
	var file = FileAccess.open("res://Data/default_save.json", FileAccess.READ)
	var content = JSON.parse_string(file.get_as_text())
	data = content
	WriteToSave(content)

func SaveScoresToFile():
	data.highscores = highscores
	WriteToSave(data)

func LoadScoresFromFile():
	var saveData = ReadSave()
	highscores = saveData.highscores

#Global stuff
func _ready():
	#Create default save if no save data exists.
	var file = FileAccess.open(path,FileAccess.READ)
	if file == null:
		CreateDefaultSave()
	LoadScoresFromFile()
	
	#Bloomies
	chapterOneBloomies.resize(chapterOneBloomieCount)
	chapterOneBloomies.fill(false)
	
	chapterOneBloomiesThisSession.resize(chapterOneBloomieCount)
	chapterOneBloomiesThisSession.fill(false)
	
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED
	process_mode = PROCESS_MODE_ALWAYS

func _process(_delta):
	pass


func BubbleSortScores() -> void: #TODO: Still need to test
	var scoresToSort = highscores.duplicate(true)
	print(str("unsorted:",scoresToSort))
	#BSort by times
	var arrSize = scoresToSort.size()
	for i in range(arrSize-1):
		for j in range(arrSize-i-1):
			if scoresToSort[j][2] > scoresToSort[j+1][2]:
				var temp = scoresToSort[j]
				scoresToSort[j] = scoresToSort[j+1]
				scoresToSort[j+1] = temp
	
	highscores = scoresToSort.duplicate(true)
	if highscores.size() > 5:
		highscores.resize(5)
	print(str("sorted:",highscores))

func UpdateScoreName(playerName:String) -> void:
	var scoreString = Global.lastScore[1]
	var score = Global.lastScore[2]
	Global.lastScore = [playerName,scoreString,score]

func AddTimeToList() -> void:
	var playerName = Global.lastScore[0]
	var timeString = Global.lastScore[1]
	var time = Global.lastScore[2]
	Global.highscores.append([playerName,timeString,time])
	Global.BubbleSortScores()
	Global.SaveScoresToFile()
