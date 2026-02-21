class_name Connect
extends "res://mods-unpacked/asdfwyay-APBuckshot/scripts/resources/common/APPacket.gd"

const NetworkVersion = preload("res://mods-unpacked/asdfwyay-APBuckshot/scripts/resources/common/NetworkVersion.gd")

@export var password: String
@export var game: String
@export var name: String
@export var uuid: String
@export var version: NetworkVersion
@export var items_handling: int
@export var tags: Array
@export var slot_data: bool


func _init(
	_password = "",
	_game = "Buckshot Roulette",
	_name = "",
	_uuid = "",
	_version = NetworkVersion.new(),
	_items_handling = 0b111,
	_tags = ["NoText"],
	_slot_data = true,
) -> void:
	cmd = "Connect"
	
	password = _password
	game = _game
	name = _name
	uuid = _uuid
	version = _version
	items_handling = _items_handling
	tags = _tags
	slot_data = _slot_data
