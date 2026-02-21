class_name Bounced
extends "res://mods-unpacked/asdfwyay-APBuckshot/scripts/resources/common/APPacket.gd"

@export var games: Array #int
@export var slots: Array #int
@export var tags: Array #int
@export var data: Dictionary


func _init(
	_games = [],
	_slots = [],
	_tags = [],
	_data = {},
) -> void:
	cmd = "Bounced"
	
	games = _games
	slots = _slots
	tags = _tags
	data = _data
