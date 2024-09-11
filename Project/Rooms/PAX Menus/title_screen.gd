extends MarginContainer

@export var chapterScreen : Control
@export var creditsScreen : Control

@onready var first_place: RichTextLabel = $"../ChapterScreen/VBoxContainer/MarginContainer/PanelContainer/VBoxContainer/MarginContainer/VBoxContainer/CenterContainer/TopRecordsTable/FirstPlace"
@onready var second_place: RichTextLabel = $"../ChapterScreen/VBoxContainer/MarginContainer/PanelContainer/VBoxContainer/MarginContainer/VBoxContainer/CenterContainer/TopRecordsTable/SecondPlace"
@onready var third_place: RichTextLabel = $"../ChapterScreen/VBoxContainer/MarginContainer/PanelContainer/VBoxContainer/MarginContainer/VBoxContainer/CenterContainer/TopRecordsTable/ThirdPlace"
@onready var fourth_place: RichTextLabel = $"../ChapterScreen/VBoxContainer/MarginContainer/PanelContainer/VBoxContainer/MarginContainer/VBoxContainer/CenterContainer/TopRecordsTable/FourthPlace"
@onready var fifth_place: RichTextLabel = $"../ChapterScreen/VBoxContainer/MarginContainer/PanelContainer/VBoxContainer/MarginContainer/VBoxContainer/CenterContainer/TopRecordsTable/FifthPlace"


func _ready() -> void:
	var arr = Global.highscores.duplicate(true)
	for i in arr.size():
		match i:
			0: 
				first_place.text = str("[center]1. ",arr[i][1], " - ", arr[i][0])
				if arr[i][0] == "YOU":
					first_place.add_theme_color_override("default_color", Color.ORANGE)
			1: 
				second_place.text = str("[center]2. ",arr[i][1], " - ", arr[i][0],)
				if arr[i][0] == "YOU":
					second_place.add_theme_color_override("default_color", Color.ORANGE)
			2: 
				third_place.text = str("[center]3. ",arr[i][1], " - ", arr[i][0],)
				if arr[i][0] == "YOU":
					third_place.add_theme_color_override("default_color", Color.ORANGE)
			3: 
				fourth_place.text = str("[center]4. ",arr[i][1], " - ", arr[i][0],)
				if arr[i][0] == "YOU":
					fourth_place.add_theme_color_override("default_color", Color.ORANGE)
			4: 
				fifth_place.text = str("[center]5. ",arr[i][1], " - ", arr[i][0],)
				if arr[i][0] == "YOU":
					fifth_place.add_theme_color_override("default_color", Color.ORANGE)
	var sizeArr = arr.size()
	if sizeArr <= 4:
		fifth_place.text = "[center]5. --:--"
	if sizeArr <= 3:
		fourth_place.text = "[center]4. --:--"
	if sizeArr <= 2:
		third_place.text = "[center]3. --:--"
	if sizeArr <= 1:
		second_place.text = "[center]2. --:--"

func _input(event: InputEvent) -> void:
	if self.visible == true and event.is_pressed():
		chapterScreen.visible = true
		self.visible = false

func _on_credits_button_pressed() -> void:
	creditsScreen.visible = true
	chapterScreen.visible = false

func _on_credits_return_button_pressed() -> void:
	chapterScreen.visible = true
	creditsScreen.visible = false
