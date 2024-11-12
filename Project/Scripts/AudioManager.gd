extends Node
## Plays and switches between music
## Plays SFX in free audio channels


## Music Files ================================================================/===================/
const MUSIC_ENCHANTED_FOREST = preload("res://Sounds/BGM/Si - Enchanted Forest.mp3")
const MUSIC_SPLASH = preload("res://Sounds/BGM/Splash - Spiff Tune  Chiptune [No Copyright Music].mp3")
const MUSIC_WOLF = preload("res://Sounds/BGM/Wolf - Jeremy L  Chiptune [No Copyright Music].mp3")

## SFX Files ==================================================================/===================/
const FAST_WIND = preload("res://Sounds/JavierSounds/fastWind.wav")
const SPEAR_SHOOT = preload("res://Sounds/JavierSounds/spearShoot.wav")
const SPRING = preload("res://Sounds/JavierSounds/spring.wav")
const WOOD_IMPACT = preload("res://Sounds/JavierSounds/woodImpact.wav")

const DOOR1 = preload("res://Sounds/JavierSounds/doorOpen (1).wav")
const DOOR2 = preload("res://Sounds/JavierSounds/doorOpen (2).wav")
const DOOR3 = preload("res://Sounds/JavierSounds/doorOpen (3).wav")
const DOOR4 = preload("res://Sounds/JavierSounds/doorOpen (4).wav")

const WOOSH1 = preload("res://Sounds/JavierSounds/woosh (1).wav")
const WOOSH2 = preload("res://Sounds/JavierSounds/woosh (2).wav")
const WOOSH3 = preload("res://Sounds/JavierSounds/woosh (3).wav")


const AUTOPULL = preload("res://Sounds/Effects/AutoPull.wav")
const COLLECT_BLOOMIE = preload("res://Sounds/Effects/collectBloomie.wav")
const PULLJUMP = preload("res://Sounds/Effects/pullJump.wav")
const SPLASH_SCREEN = preload("res://Sounds/SplashScreenSound.wav")

const HOOK1 = preload("res://Sounds/Effects/click.wav")
const HOOK2 = preload("res://Sounds/Effects/click (1).wav")

const JUMP1 = preload("res://Sounds/Effects/jump (1).wav")
const JUMP2 = preload("res://Sounds/Effects/jump (2).wav")
const JUMP3 = preload("res://Sounds/Effects/jump (3).wav")

const STEPS1 = preload("res://Sounds/Effects/steps1.wav")
const STEPS2 = preload("res://Sounds/Effects/steps2.wav")
const STEPS3 = preload("res://Sounds/Effects/steps3.wav")

## ============================================================================/===================/


var music_pause_point = 0

@onready var mixer_master = AudioServer.get_bus_index("Master")
@onready var mixer_music = AudioServer.get_bus_index("Music")
@onready var mixer_sfx = AudioServer.get_bus_index("SFX")

@onready var music_player: AudioStreamPlayer = $MusicPlayer
@onready var sfx_player: Node = $SFXplayer

## Play sound in a free audio channel. Return true when a channel is found, and false otherwise.
func play_sound(sound: Resource) -> bool:
	for channel in sfx_player.get_children():
		if channel is AudioStreamPlayer and not channel.playing:
			channel.stream = sound
			channel.play()
			return true
	return false

## Play random sound out of options. Return true when a channel is found, and false otherwise.
func play_sound_random(s1: Resource = null, s2: Resource = null, s3: Resource = null, s4: Resource = null) -> bool:
	# Because variable arguments aren't supported :(
	var sound_pool = []
	for argument in [s1, s2, s3, s4]:
		if argument != null:
			sound_pool.push_back(argument)
	
	if sound_pool.size() > 0:
		return play_sound(sound_pool.pick_random())
	return false

## Play specific music. Return true when executed.
func play_music(music) -> bool:
	if (music_player.playing == true):
		music_player.stop()
	music_pause_point = 0
	music_player.stream = music
	music_player.play()
	return true

## Pause music. Return true when executed, and false if there is no music playing.
func pause_current_music() -> bool:
	if (music_player.playing == true):
		music_pause_point = music_player.get_playback_position()
		music_player.stop()
		return true
	else:
		return false

## Resume music. Return true when executed, and false if there is already music playing.
func resume_current_music():
	if (music_player.playing == false):
		music_pause_point = 0
		music_player.play()
		return true
	else:
		return false

func _ready():
	self.process_mode = Node.PROCESS_MODE_ALWAYS
