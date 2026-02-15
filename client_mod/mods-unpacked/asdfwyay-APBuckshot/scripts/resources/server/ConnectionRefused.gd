class_name ConnectionRefused
extends "res://mods-unpacked/asdfwyay-APBuckshot/scripts/resources/common/APPacket.gd"

@export var errors: Array #String

func _init(_errors = []) -> void:
	cmd = "ConnectionRefused"
	
	errors = _errors
