class_name LocationScouts
extends "res://mods-unpacked/asdfwyay-APBuckshot/scripts/resources/common/APPacket.gd"

@export var locations: Array[int]
@export var create_as_hint: int

func _init(_locations = [], _create_as_hint = 0) -> void:
	cmd = "LocationScouts"
	
	locations = _locations
	create_as_hint = _create_as_hint
