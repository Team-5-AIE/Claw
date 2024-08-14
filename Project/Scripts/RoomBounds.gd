@tool
extends CollisionShape2D

# ---Functions---
# Godot functions
func _ready():
    %PlayerCamera.m_roomBounds = self
