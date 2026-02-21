class_name LocationInfo
extends "res://mods-unpacked/asdfwyay-APBuckshot/scripts/resources/common/APPacket.gd"

@export var locations: Array[NetworkItem]


func _init(_locations = []) -> void:
	cmd = "LocationInfo"
	
	locations = _locations
