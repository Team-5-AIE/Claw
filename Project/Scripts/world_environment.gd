extends WorldEnvironment
@onready var fade: Timer = $Fade

var bloom = 0.2
var bloomTracker = false
func SaturationFadeOut() -> void:
	fade.start()


func _on_fade_in_timeout() -> void:
	if bloomTracker: environment.glow_bloom -= randf_range(0.02,0.04)
	else: environment.glow_bloom += randf_range(0.02,0.04)
	
	if environment.glow_bloom <= bloom && bloomTracker:
		bloomTracker = false
		
	if environment.glow_bloom >= 0.8 && !bloomTracker:
		bloomTracker = true
	fade.start()
	

func StartLevel() -> void:
	environment.glow_bloom = 1
	fade.start()
