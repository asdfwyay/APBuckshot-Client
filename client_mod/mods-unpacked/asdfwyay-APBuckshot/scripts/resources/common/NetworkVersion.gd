class_name NetworkVersion
extends "res://mods-unpacked/asdfwyay-APBuckshot/scripts/resources/common/APPacket.gd"

@export var major: int
@export var minor: int
@export var build: int

func _init(_major = 0, _minor = 6, _build = 6) -> void:
	cmd = ""
	
	major = _major
	minor = _minor
	build = _build

func to_dict() -> Dictionary:
	return {
		"class": "Version",
		"build": build,
		"major": major,
		"minor": minor
	}
