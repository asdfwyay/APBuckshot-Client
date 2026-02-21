class_name ConnectUpdate
extends "res://mods-unpacked/asdfwyay-APBuckshot/scripts/resources/common/APPacket.gd"

@export var items_handling: int
@export var tags: Array


func _init(_items_handling = 0b111, _tags = []) -> void:
	cmd = "ConnectUpdate"
	
	items_handling = _items_handling
	tags = _tags
