class_name SetNotify
extends "res://mods-unpacked/asdfwyay-APBuckshot/scripts/resources/common/APPacket.gd"

var keys: Array #String


func _init(_keys) -> void:
	cmd = "SetNotify"
	
	keys = _keys
