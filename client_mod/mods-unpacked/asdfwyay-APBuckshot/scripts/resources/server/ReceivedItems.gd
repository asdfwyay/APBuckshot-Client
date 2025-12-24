class_name ReceivedItems
extends "res://mods-unpacked/asdfwyay-APBuckshot/scripts/resources/common/APPacket.gd"

@export var index: int
@export var items: Array

func _init(_index = 0, _items = []) -> void:
	cmd = "ReceivedItems"
	
	index = _index
	items = _items
