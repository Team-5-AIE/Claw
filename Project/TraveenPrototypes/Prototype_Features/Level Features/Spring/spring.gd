extends Area2D

@export_group("Directional Activation")
@export_enum("None", "-180 to 180", "-90 to 90") var directionalCondition: int = 0
@export_range(0, 1) var strictnessThreshold: float = 0
@export_group("")
@export var springStrength: float = 350
@export_range(-90, 90) var launchAngle: float = 0
@export_range(0, 1) var launchStopFraction: float = 0.8

var launchDirection: Vector2
var minSimilarity: float

func _ready() -> void:
	launchDirection = Vector2.UP.rotated(self.rotation + deg_to_rad(launchAngle))
	
	match (directionalCondition):
		1:
			minSimilarity = lerpf(-1, 1, strictnessThreshold)
		2:
			minSimilarity = lerpf(0, 1, strictnessThreshold)
		_:
			minSimilarity = -1

func _on_body_entered(body: Node2D) -> void:
	if body is SWPlatformerCharacter:
		var playerVelSimilarity: float = body.velocity.normalized().dot(Vector2.DOWN.rotated(self.rotation))
		if playerVelSimilarity >= strictnessThreshold:
			body.velocity *= 1 - launchStopFraction
			body.velocity += launchDirection * springStrength
