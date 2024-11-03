extends Node

enum Chapters {CHAPTER_ZERO = 0, CHAPTER_ONE = 1, CHAPTER_TWO = 2, CHAPTER_TEST = -1 }

# Chapter specific flag counts as separate vars, 
# with some functionality to choose which one to use when creating chapter array
var chapterTestFlagCount: int = 32

var chapterFlags: Array[bool]

# Create chapter flag array of specified size and fill it with false flags
func create_flag_array(chapter_id: Chapters = Chapters.CHAPTER_TEST) -> void:
	var flag_count: int
	
	match (chapter_id):
		#Chapters.CHAPTER_ZERO:
			#pass
		#Chapters.CHAPTER_ONE:
			#pass
		#Chapters.CHAPTER_TWO:
			#pass
		_:
			flag_count = chapterTestFlagCount
	
	chapterFlags.resize(flag_count)
	chapterFlags.fill(false)
