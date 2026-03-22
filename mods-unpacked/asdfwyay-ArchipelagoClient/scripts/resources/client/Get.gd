class_name Get
extends "res://mods-unpacked/asdfwyay-ArchipelagoClient/scripts/resources/common/APPacket.gd"

@export var keys: Array #String


func _init(_keys = []) -> void:
	cmd = "Get"
	
	keys = _keys
