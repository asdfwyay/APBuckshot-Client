class_name NetworkSlot
extends "res://mods-unpacked/asdfwyay-APBuckshot/scripts/resources/common/APPacket.gd"

enum SlotType {
	SPECTATOR = 0b00,
	PLAYER = 0b01,
	GROUP = 0b10
}

@export var name: String
@export var game: String
@export var type: SlotType
@export var group_members: Array[int]

func _init(_name = "", _game = "", _type = SlotType.SPECTATOR, _group_members = []) -> void:
	cmd = ""
	
	name = _name
	game = _game
	type = _type
	group_members = _group_members
