class_name LocationChecks
extends "res://mods-unpacked/asdfwyay-ArchipelagoClient/scripts/resources/common/APPacket.gd"

@export var locations: Array


func _init(_locations = []) -> void:
	cmd = "LocationChecks"
	
	locations = _locations
