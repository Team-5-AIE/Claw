@tool
extends ColorRect

var pointLightObjects : Array[Node2D]
var player : SWPlatformerCharacter
var playerCam : Camera2D

var lightingEnabled : bool:
	set(value):
		lightingEnabled = value
		material.set_shader_parameter("lightingEnabled", lightingEnabled)

# ---Functions---
func _process(_delta):
	if !Engine.is_editor_hint():
		if player == null:
			var rtnArray = get_tree().get_nodes_in_group("Player")
			if (rtnArray.size() > 0):
				player = rtnArray[0]
				playerCam = player.get_node("PlayerCamera")
			
			var rtnArray2 = get_tree().get_nodes_in_group("PointLights")
			pointLightObjects.assign(rtnArray2)
		else:
			var pointLights : PackedVector3Array = material.get_shader_parameter("pointLights")
			
			for i : int in pointLightObjects.size():
				pointLights[i].x = pointLightObjects[i].global_position.x + 320
				pointLights[i].y = pointLightObjects[i].global_position.y + 180
				pointLights[i].z = pointLightObjects[i].lightIntensity
				
				if i == pointLightObjects.size() - 1:
					pointLights[i + 1].z = -1
			
			material.set_shader_parameter("pointLights", pointLights)
			
			material.set_shader_parameter("camOffset", playerCam.get_screen_center_position())

func _unhandled_input(event):
	if !Engine.is_editor_hint():
		if event.is_action_pressed("ShaderToggle"):
			visible = !visible
