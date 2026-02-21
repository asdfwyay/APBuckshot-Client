class_name UpdateHint
extends "res://mods-unpacked/asdfwyay-APBuckshot/scripts/resources/common/APPacket.gd"

enum HintStatus {
	HINT_UNSPECIFIED = 0,
	HINT_NO_PRIORITY = 10,
	HINT_AVOID = 20,
	HINT_PRIORITY = 30,
	HINT_FOUND = 40
}

@export var player: int
@export var location: int
@export var status: HintStatus


func _init(_player = 0, _location = 0, _status = HintStatus.HINT_UNSPECIFIED) -> void:
	cmd = "UpdateHint"
	
	player = _player
	location = _location
	status = _status
