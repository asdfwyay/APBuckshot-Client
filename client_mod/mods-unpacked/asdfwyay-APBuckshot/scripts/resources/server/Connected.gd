class_name Connected
extends "res://mods-unpacked/asdfwyay-APBuckshot/scripts/resources/common/APPacket.gd"

@export var team: int
@export var slot: int
@export var players: Array #NetworkPlayer
@export var missing_locations: Array #int
@export var checked_locations: Array #int
@export var slot_data: Dictionary #[String, Variant]
@export var slot_info: Dictionary #[int, NetworkSlot]
@export var hint_points: int


func _init(
	_team = 0,
	_slot = 1,
	_players = [],
	_missing_locations = [],
	_checked_locations = [],
	_slot_data = {},
	_slot_info = {},
	_hint_points = 0,
) -> void:
	cmd = "Connected"
	
	team = _team
	slot = _slot
	players = _players
	missing_locations = _missing_locations
	checked_locations = _checked_locations
	slot_data = _slot_data
	slot_info = _slot_info
	hint_points = _hint_points
