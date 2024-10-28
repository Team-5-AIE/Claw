class_name Switch
extends LevelActivator

@export var flagID : int :
	get:
		return _flag_ID
	set(value):
		_flag_ID = value

var switchState : bool :
	get:
		return is_active
	set(value):
		if is_active != value:
			is_active = value
		if on_sprite != null and off_sprite != null:
			on_sprite.visible = value
			off_sprite.visible = !value

var spear: Spear = null

@onready var active_collision: CollisionShape2D = $CollisionShape2D
@onready var on_sprite: Sprite2D = $OnSprite
@onready var off_sprite: Sprite2D = $OffSprite


# Guard to force inherited scripts to use this method
func _init() -> void:
	assert(self.has_method("use_switch"), "Method use_switch not found in Switch: " + str(self))

func _ready() -> void:
	super()
	switchState = is_active

# Connect spear to this script when it enters
func _on_spear_detector_body_entered(body: Node2D) -> void:
	if body is Spear and not body.retracted:
		spear = body

# Call use_switch when spear starts retracting
func _physics_process(delta: float) -> void:
	if spear != null and spear.retracted:
		spear = null
		Callable(self, "use_switch").call()
