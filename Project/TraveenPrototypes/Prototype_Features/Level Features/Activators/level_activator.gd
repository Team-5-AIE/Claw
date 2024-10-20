class_name LevelActivator
extends Node

signal deactivated(switchID)
signal activated(switchID)

signal startup_deactivated(switchID)
signal startup_activated(switchID)

var switchID: int
