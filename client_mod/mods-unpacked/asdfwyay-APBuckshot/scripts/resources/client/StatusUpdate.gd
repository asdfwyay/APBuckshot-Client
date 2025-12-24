class_name StatusUpdate
extends "res://mods-unpacked/asdfwyay-APBuckshot/scripts/resources/common/APPacket.gd"

enum ClientStatus {
	CLIENT_UNKNOWN = 0,
	CLIENT_CONNECTED = 5,
	CLIENT_READY = 10,
	CLIENT_PLAYING = 20,
	CLIENT_GOAL = 30
}

@export var status: ClientStatus

func _init(_status = ClientStatus.CLIENT_UNKNOWN) -> void:
	cmd = "StatusUpdate"
	
	status = _status
