extends Control

@onready var first_place: RichTextLabel = $TopRecordsTable/FirstPlace
@onready var second_place: RichTextLabel = $TopRecordsTable/SecondPlace
@onready var third_place: RichTextLabel = $TopRecordsTable/ThirdPlace
@onready var fourth_place: RichTextLabel = $TopRecordsTable/FourthPlace
@onready var fifth_place: RichTextLabel = $TopRecordsTable/FifthPlace
@onready var player_name_input: LineEdit = $ChapterScreen/MarginContainer/PanelContainer/VBoxContainer/HBoxContainer/PlayerNameInput

@onready var player_time: RichTextLabel = $ChapterScreen/MarginContainer/PanelContainer/VBoxContainer/PlayerTime

@export_file("*.tscn") var mainMenuScenePath : String

func _ready() -> void: 
	first_place.text = ""
	player_time.text = str("[center]","YOUR TIME: ",Global.lastScore[0][1],"[/center]")
	var timeString = Global.lastScore[0][1]
	var time = Global.lastScore[0][2]
	var newArr = Global.highscores.duplicate(true)
	newArr.append(["YOU",timeString,time])
	newArr = Sort(newArr)
	#[Name, Score as string, time]
	for i in newArr.size():
		match i:
			0: 
				first_place.text = str(" 1. ",newArr[i][1], " - ", newArr[i][0])
				if newArr[i][0] == "YOU":
					first_place.add_theme_color_override("default_color", Color.ORANGE)
			1: 
				second_place.text = str(" 2. ",newArr[i][1], " - ", newArr[i][0],)
				if newArr[i][0] == "YOU":
					second_place.add_theme_color_override("default_color", Color.ORANGE)
			2: 
				third_place.text = str(" 3. ",newArr[i][1], " - ", newArr[i][0],)
				if newArr[i][0] == "YOU":
					third_place.add_theme_color_override("default_color", Color.ORANGE)
			3: 
				fourth_place.text = str(" 4. ",newArr[i][1], " - ", newArr[i][0],)
				if newArr[i][0] == "YOU":
					fourth_place.add_theme_color_override("default_color", Color.ORANGE)
			4: 
				fifth_place.text = str(" 5. ",newArr[i][1], " - ", newArr[i][0],)
				if newArr[i][0] == "YOU":
					fifth_place.add_theme_color_override("default_color", Color.ORANGE)
	var sizeArr = newArr.size()
	if sizeArr <= 4:
		fifth_place.text = " 5. --:--"
	if sizeArr <= 3:
		fourth_place.text = " 4. --:--"
	if sizeArr <= 2:
		third_place.text = " 3. --:--"
	if sizeArr <= 1:
		second_place.text = " 2. --:--"

func Sort(scoresToSort) ->Array:
	print(str("unsorted:",scoresToSort))
	#BSort by times
	var arrSize = scoresToSort.size()
	for i in range(arrSize-1):
		for j in range(arrSize-i-1):
			if scoresToSort[j][2] > scoresToSort[j+1][2]:
				var temp = scoresToSort[j]
				scoresToSort[j] = scoresToSort[j+1]
				scoresToSort[j+1] = temp
	return scoresToSort


func _on_submit_button_pressed() -> void:
	Global.UpdateScoreName(player_name_input.text)
	Global.AddTimeToList()
	# Go back to menu
	FadeTransitions.Transition()
	await FadeTransitions.on_fade_in_finished
	
	get_tree().change_scene_to_file(mainMenuScenePath)
	
	await FadeTransitions.on_fade_out_finished