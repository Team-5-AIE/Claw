extends Node

var totalBloomiesCollected : int = 0
var chapterOneBloomies : Array[bool]
var chapterOneBloomieCount = 5

#This holds all the data of score entry
#first entry is the latest one.
var lastScore = [] #[Name, Score as string, minutes, seconds] 

#This holds all the data of score entry
#First entry is the fastest time - accending order. 
var highscores = [] #[Name, Score as string, minutes, seconds]

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
	else:
		LoadScoresFromFile()
		
	#Bloomies
	chapterOneBloomies.resize(chapterOneBloomieCount)
	chapterOneBloomies.fill(false)

func _process(_delta):
	pass

#func GetHighscoresAsStringArray() -> Array: #TODO: Still need to test
	#var stringHighscores = []
	#for score in highscores:
		#stringHighscores.append([str("Name:",score[0],"|Time:", score[1])])
	#print(stringHighscores)
	#return stringHighscores

#func SortScores() -> void: #TODO: Still need to test
	#var highscoresSorted = highscores.duplicate(true)
	#print(str("unsorted:",highscores))
	##Sort minutes
	#for score in range(highscoresSorted.size()):
		#if highscoresSorted.has([score+1]):
			#if highscoresSorted[score][2] > highscoresSorted[score+1][2]: 
				## The minutes of this score is more than the next score - swap
				#var temp = highscoresSorted[score]
				#highscoresSorted[score] = highscoresSorted[score+1]
				#highscoresSorted[score+1] = temp
	##Sort seconds
	#for score in range(highscoresSorted.size()):
		#if highscoresSorted.has([score+1]): 
			#if highscoresSorted[score][3] > highscoresSorted[score+1][3]: 
				## The seconds of this score is more than the next score - swap
				#var temp = highscoresSorted[score]
				#highscoresSorted[score] = highscoresSorted[score+1]
				#highscoresSorted[score+1] = temp
	#highscores = highscoresSorted.duplicate(true)
	#print(str("sorted:",highscores))
