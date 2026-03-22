class_name Set
extends "res://mods-unpacked/asdfwyay-APBuckshot/scripts/resources/common/APPacket.gd"

var key: String
var default: Variant
var want_reply: bool
var operations: Dictionary


func _init(_key, _default, _want_reply, _operations) -> void:
	cmd = "Set"
	
	key = _key
	default = _default
	want_reply = _want_reply
	operations = _operations
