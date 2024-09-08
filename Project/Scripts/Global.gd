extends Node

var totalBloomiesCollected : int = 0
var chapterOneBloomies : Array[bool]
var chapterOneBloomieCount = 5

#This holds all the data of score entry
#first entry is the latest one.
var highscores = [] #[Name, Score as string, minutes, seconds] 

#This holds all the data of score entry
#First entry is the fastest time - accending order. 
var sortedHighscores = [] #[Name, Score as string, minutes, seconds]

func _ready():
	chapterOneBloomies.resize(chapterOneBloomieCount)
	chapterOneBloomies.fill(false)

func _process(_delta):
	pass

func GetHighscoresAsStringArray() -> Array: #TODO: Still need to test
	var stringHighscores = []
	for score in highscores:
		stringHighscores.append(str("Name:",score[0],"|Time:", score[1]))
	print(stringHighscores)
	return stringHighscores

func SortScores() -> void: #TODO: Still need to test
	sortedHighscores = highscores.duplicate(true)
	#Sort minutes
	for score in range(highscores.size()):
		if highscores[score][2] > highscores[score+1][2]: 
			# The minutes of this score is more than the next score - swap
			var temp = highscores[score]
			highscores[score] = highscores[score+1]
			highscores[score+1] = temp
	#Sort seconds
	for score in range(highscores.size()):
		if highscores[score][3] > highscores[score+1][3]: 
			# The seconds of this score is more than the next score - swap
			var temp = highscores[score]
			highscores[score] = highscores[score+1]
			highscores[score+1] = temp
