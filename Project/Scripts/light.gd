@tool
extends Node2D

@export var lightIntensity : float:
	set(value):
		lightIntensity = value
		if Engine.is_editor_hint():
			queue_redraw()
@export var intensityFlickerAmount : float
@export var intensityFlickerSpeed : float
@export var movementFlickerDistance : float
@export var movementFlickerSpeed : float

@onready var originalIntensity : float = lightIntensity
@onready var oldIntensity : float = lightIntensity
var targetIntensity : float
var intensityTimer : float

@onready var originalPos : Vector2 = position
@onready var oldPos : Vector2 = position
var targetPos : Vector2
var moveTimer : float

func _draw():
	if Engine.is_editor_hint():
		draw_circle(Vector2(0, 0), lightIntensity, Color(1, 1, 1, 0.5))

func _ready():
	randomize()
	targetIntensity = originalIntensity + randf_range(-intensityFlickerAmount, intensityFlickerAmount)
	targetPos = originalPos + \
	Vector2(randf_range(-movementFlickerDistance, movementFlickerDistance),\
	randf_range(-movementFlickerDistance, movementFlickerDistance))

func _process(delta):
	if ! Engine.is_editor_hint():
		intensityTimer += delta * intensityFlickerSpeed
		
		lightIntensity = lerp(oldIntensity, targetIntensity, min(intensityTimer, 1))
		
		if intensityTimer > 1:
			intensityTimer = 0
			oldIntensity = lightIntensity
			targetIntensity = originalIntensity + randf_range(-intensityFlickerAmount, intensityFlickerAmount)
		
		moveTimer += delta * movementFlickerSpeed
		
		position = lerp(oldPos, targetPos, min(moveTimer, 1))
		
		if moveTimer > 1:
			moveTimer = 0
			oldPos = position
			targetPos = originalPos + \
			Vector2(randf_range(-movementFlickerDistance, movementFlickerDistance),\
			randf_range(-movementFlickerDistance, movementFlickerDistance))
