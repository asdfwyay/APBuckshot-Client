class_name ConnectionRefused
extends "res://mods-unpacked/asdfwyay-ArchipelagoClient/scripts/resources/common/APPacket.gd"

@export var errors: Array #String


func _init(_errors = []) -> void:
	cmd = "ConnectionRefused"
	
	errors = _errors
