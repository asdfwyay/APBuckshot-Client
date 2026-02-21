class_name DataPackage
extends "res://mods-unpacked/asdfwyay-APBuckshot/scripts/resources/common/APPacket.gd"

@export var data: Dictionary


func _init(
	_games = [],
	_slots = [],
	_tags = [],
	_data = {},
) -> void:
	cmd = "DataPackage"
	
	data = _data
