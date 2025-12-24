class_name NetworkPlayer
extends "res://mods-unpacked/asdfwyay-APBuckshot/scripts/resources/common/APPacket.gd"

@export var team: int
@export var slot: int
@export var alias: String
@export var name: String

func _init(_team = 0, _slot = 1, _alias = "", _name = "") -> void:
	cmd = ""
	
	team = _team
	slot = _slot
	alias = _alias if _alias else _name
	name = _name
