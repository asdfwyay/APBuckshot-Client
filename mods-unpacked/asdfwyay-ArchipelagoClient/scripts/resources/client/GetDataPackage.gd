class_name GetDataPackage
extends "res://mods-unpacked/asdfwyay-ArchipelagoClient/scripts/resources/common/APPacket.gd"

@export var games: Array


func _init(_games = []) -> void:
	cmd = "GetDataPackage"
	
	games = _games
