extends MarginContainer

func _ready() -> void:
	self.visible = true
	$"../BackgroundList/TitleBG".visible = true
	$"../ChapterScreen".visible = false
	$"../BackgroundList/ChapterOneBG".visible = false

func _unhandled_input(event: InputEvent) -> void:
	if event is not InputEventMouseMotion and event is not InputEventJoypadMotion:
		$"../ChapterScreen".visible = true
		$"../BackgroundList/ChapterOneBG".visible = true
		$"../BackgroundList/TitleBG".visible = false
		self.visible = false
