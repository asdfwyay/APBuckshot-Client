class_name RoomInfo
extends "res://mods-unpacked/asdfwyay-APBuckshot/scripts/resources/common/APPacket.gd"

const NetworkVersion = preload("res://mods-unpacked/asdfwyay-APBuckshot/scripts/resources/common/NetworkVersion.gd")

enum Permission {
	DISABLED = 0b000,
	ENABLED = 0b001,
	GOAL = 0b010,
	AUTO = 0b110,
	AUTO_ENABLED = 0b111
}

@export var version: NetworkVersion
@export var generator_version: NetworkVersion
@export var tags: Array
@export var password: bool
@export var permissions: Dictionary #[String, Permission]
@export var hint_cost: int
@export var location_check_points: int
@export var games: Array = []
@export var datapackage_checksums: Dictionary #[String, String]
@export var seed_name: String
@export var time: float


func _init(
	_version = NetworkVersion.new(),
	_generator_version = NetworkVersion.new(),
	_tags = [],
	_password = false,
	_permissions = {},
	_hint_cost = 0,
	_location_check_points = 0,
	_games = [],
	_datapackage_checksums = {},
	_seed_name = "",
	_time = 0.0,
) -> void:
	cmd = "RoomInfo"
	
	version = _version
	generator_version = _generator_version
	tags = _tags
	password = _password
	permissions = _permissions
	hint_cost = _hint_cost
	location_check_points = _location_check_points
	games = _games
	datapackage_checksums = _datapackage_checksums
	seed_name = _seed_name
	time = _time
