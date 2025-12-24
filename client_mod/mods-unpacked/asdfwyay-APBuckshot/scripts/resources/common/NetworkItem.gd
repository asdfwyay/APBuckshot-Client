class_name NetworkItem
extends "res://mods-unpacked/asdfwyay-APBuckshot/scripts/resources/common/APPacket.gd"

@export var item: int
@export var location: int
@export var player: int
@export var flags: int

func _init(_item = 0, _location = 1, _player = "", _flags = "") -> void:
	cmd = ""
	
	item = _item
	location = _location
	player = _player
	flags = _flags
