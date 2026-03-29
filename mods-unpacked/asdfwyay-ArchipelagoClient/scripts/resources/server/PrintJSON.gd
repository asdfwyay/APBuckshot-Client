class_name PrintJSON
extends "res://mods-unpacked/asdfwyay-ArchipelagoClient/scripts/resources/common/APPacket.gd"

const NetworkItem = preload("res://mods-unpacked/asdfwyay-ArchipelagoClient/scripts/resources/common/NetworkItem.gd")

@export var data: Array #JSONMessagePart
@export var type: String
@export var receiving: int
@export var item: Dictionary
@export var found: bool
@export var team: int
@export var slot: int
@export var message: String
@export var tags: Array #String
@export var countdown: int


func _init(
	_data = [],
	_type = "",
	_receiving = 0,
	_item = {},
	_found = false,
	_team = 0,
	_slot = 1,
	_message = "",
	_tags = [],
	_countdown = 0,
) -> void:
	cmd = "PrintJSON"
	
	data = _data
	type = _type
	receiving = _receiving
	item = _item
	found = _found
	team = _team
	slot = _slot
	message = _message
	tags = _tags
	countdown = _countdown
