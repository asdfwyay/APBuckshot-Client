class_name JSONMessagePart
extends "res://mods-unpacked/asdfwyay-APBuckshot/scripts/resources/common/APPacket.gd"

enum HintStatus {
	HINT_UNSPECIFIED = 0,
	HINT_NO_PRIORITY = 10,
	HINT_AVOID = 20,
	HINT_PRIORITY = 30,
	HINT_FOUND = 40
}

@export var type: String
@export var text: String
@export var color: String
@export var flags: int
@export var player: int
@export var hint_status: HintStatus


func _init(
	_type = "text",
	_text = "",
	_color = "black",
	_flags = 0,
	_player = 0,
	_hint_status = HintStatus.HINT_UNSPECIFIED,
) -> void:
	cmd = ""
	
	type = _type
	text = _text
	color = _color
	flags = _flags
	player = _player
	hint_status = _hint_status
