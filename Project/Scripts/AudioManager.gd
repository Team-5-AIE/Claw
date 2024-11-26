extends Node
## Plays and switches between music
## Plays SFX in free audio channels


## Music Files ================================================================/===================/
const MUSIC_ENCHANTED_FOREST = preload("res://Sounds/BGM/Si - Enchanted Forest.mp3")
const MUSIC_SPLASH = preload("res://Sounds/BGM/Splash - Spiff Tune  Chiptune [No Copyright Music].mp3")
const MUSIC_WOLF = preload("res://Sounds/BGM/Wolf - Jeremy L  Chiptune [No Copyright Music].mp3")

## SFX Files ==================================================================/===================/
const FAST_WIND = preload("res://Sounds/JavierSounds/fastWind.wav")
const SPRING = preload("res://Sounds/JavierSounds/spring.wav")
const WOOD_IMPACT = preload("res://Sounds/JavierSounds/woodImpact.wav")

const DOOR1 = preload("res://Sounds/JavierSounds/doorOpen (1).wav")
const DOOR2 = preload("res://Sounds/JavierSounds/doorOpen (2).wav")
const DOOR3 = preload("res://Sounds/JavierSounds/doorOpen (3).wav")
const DOOR4 = preload("res://Sounds/JavierSounds/doorOpen (4).wav")

const SHOOTSPEAR = preload("res://Sounds/JavierSounds/spearShoot.wav")
const WOOSH2 = preload("res://Sounds/JavierSounds/woosh (2).wav")
const WOOSH3 = preload("res://Sounds/JavierSounds/woosh (3).wav")

const PAGEFLIP = preload("res://Sounds/JavierSounds/pageturn-102978.mp3")
const WALLSLIDE = preload("res://Sounds/JavierSounds/wallSlide.wav")
const WALLSLIDEAFTER = preload("res://Sounds/JavierSounds/WallSlideAfter.wav")
const FLOORSLIDE = preload("res://Sounds/JavierSounds/FloorSlide.wav")
const DEATH = preload("res://Sounds/JavierSounds/deathSound.wav")

const AUTOPULL = preload("res://Sounds/Effects/AutoPull.wav")
const TOUCH_KEY = preload("res://Sounds/JavierSounds/keySparkle.wav")
const TOUCH_BLOOMIE = preload("res://Sounds/JavierSounds/BloomieGrab.wav")
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

@onready var mixer_master = AudioServer.get_bus_index("Master")
@onready var mixer_music = AudioServer.get_bus_index("Music")
@onready var mixer_sfx = AudioServer.get_bus_index("SFX")

@onready var music_player: AudioStreamPlayer = $MusicPlayer
@onready var game_sfx_player: Node = $GameSFXPlayer
@onready var menu_sfx_player: Node = $MenuSFXPlayer

## Play sound in a free audio channel in the Game SFX Player. 
## Return true when a channel is found, and false otherwise.
func play_game_sound(sound: Resource, volume: float, _sfx_player: Node = game_sfx_player) -> bool:
	for channel in _sfx_player.get_children():
		if channel is AudioStreamPlayer and not channel.playing:
			channel.stream_paused = false
			channel.stream = sound
			channel.volume_db = volume
			channel.play()
			return true
	return false

func play_modulated_game_sound(sound: Resource, volume: float, _sfx_player: Node = game_sfx_player) -> bool:
	for channel in _sfx_player.get_children():
		if channel is AudioStreamPlayer and not channel.playing:
			channel.stream_paused = false
			channel.stream = sound
			channel.volume_db = volume
			channel.pitch_scale = randf_range(0.8,1.2)
			channel.play()
			return true
	return false

## Play random game sound out of options. 
## Return true when a channel is found, and false otherwise.
func play_game_sound_random(volume: float, s1: Resource = null, s2: Resource = null, s3: Resource = null, s4: Resource = null, _sfx_player: Node = game_sfx_player) -> bool:
	# Because variable arguments aren't supported :(
	var sound_pool = []
	for argument in [s1, s2, s3, s4]:
		if argument != null:
			sound_pool.push_back(argument)
	
	if sound_pool.size() > 0:
		
		return play_game_sound(sound_pool.pick_random(), volume,_sfx_player)
	return false

func play_game_sound_random_modulated(volume: float, s1: Resource = null, s2: Resource = null, s3: Resource = null, s4: Resource = null, _sfx_player: Node = game_sfx_player) -> bool:
	# Because variable arguments aren't supported :(
	var sound_pool = []
	for argument in [s1, s2, s3, s4]:
		if argument != null:
			sound_pool.push_back(argument)
	
	if sound_pool.size() > 0:
		
		return play_modulated_game_sound(sound_pool.pick_random(), volume, _sfx_player)
	return false

## Pause all currently playing game sounds. 
## Return true when it pauses a game SFX channel, and false when it couldn't pause any of them.
func pause_all_game_sounds(_sfx_player: Node = game_sfx_player) -> bool:
	var paused: bool = false
	for channel in _sfx_player.get_children():
		if channel is AudioStreamPlayer and not channel.stream_paused:
				channel.stream_paused = true
				paused = true
	return paused

## Resume all paused game sound channels. 
## Return true when it resumes one of them, and false when it couldn't resume any of them.
func resume_all_game_sounds(_sfx_player: Node = game_sfx_player) -> bool:
	var resumed: bool = false
	for channel in _sfx_player.get_children():
		if channel is AudioStreamPlayer and channel.stream_paused:
				channel.stream_paused = false
				resumed = true
	return resumed

## Play sound in a free audio channel in the Menu SFX Player. 
## Return true when a channel is found, and false otherwise.
func play_menu_sound(sound: Resource, volume: float,) -> bool:
	return play_game_sound(sound, volume, menu_sfx_player)

## Play random menu sound out of options. 
## Return true when a channel is found, and false otherwise.
func play_menu_sound_random(volume: float, s1: Resource = null, s2: Resource = null, s3: Resource = null, s4: Resource = null) -> bool:
	return play_game_sound_random(volume, s1, s2, s3, s4, menu_sfx_player)

## Pause all currently playing menu sounds. 
## Return true when it pauses a menu SFX channel, and false when it couldn't pause any of them.
func pause_all_menu_sounds() -> bool:
	return pause_all_game_sounds(menu_sfx_player)

## Resume all paused menu sound channels. 
## Return true when it resumes one of them, and false when it couldn't resume any of them.
func resume_all_menu_sounds() -> bool:
	return resume_all_game_sounds(menu_sfx_player)

## Play specific music. 
## Return true when executed, and false if music is already playing when not forcing start
func play_music(music: Resource, volume: float, force_start: bool = true) -> bool:
	if music_player.playing:
		if force_start: music_player.stop()
		else: return false
	music_player.stream_paused = false
	music_player.stream = music
	music_player.volume_db = volume
	music_player.play()
	
	return true

## Pause music. 
## Return true when executed, and false if there is no music playing.
func pause_current_music() -> bool:
	if music_player.playing and not music_player.stream_paused:
		music_player.stream_paused = true
		return true
	else:
		return false

## Resume music. 
## Return true when executed, and false if there is already music playing.
func resume_current_music():
	if music_player.stream_paused:
		music_player.stream_paused = false
		return true
	else:
		return false

func _ready():
	self.process_mode = Node.PROCESS_MODE_ALWAYS


func _on_music_player_finished() -> void:
	music_player.play()
