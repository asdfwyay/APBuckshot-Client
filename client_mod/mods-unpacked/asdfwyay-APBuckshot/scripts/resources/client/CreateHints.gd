class_name CreateHints
extends "res://mods-unpacked/asdfwyay-APBuckshot/scripts/resources/common/APPacket.gd"

enum HintStatus {
	HINT_UNSPECIFIED = 0,
	HINT_NO_PRIORITY = 10,
	HINT_AVOID = 20,
	HINT_PRIORITY = 30,
	HINT_FOUND = 40
}

@export var locations: Array[int]
@export var player: int
@export var status: HintStatus

func _init(_locations = [], _player = 0, _status = HintStatus.HINT_UNSPECIFIED) -> void:
	cmd = "CreateHints"
	
	locations = _locations
	player = _player
	status = _status
