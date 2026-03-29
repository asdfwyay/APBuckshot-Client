class_name Say
extends "res://mods-unpacked/asdfwyay-ArchipelagoClient/scripts/resources/common/APPacket.gd"

@export var text: String


func _init(_text = "") -> void:
	cmd = "Say"
	
	text = _text
