extends Node

var ApClient

@onready var slot_input: LineEdit = $BaseMenu/VBoxContainer/GridContainer/slot_input
@onready var host_input: LineEdit = $BaseMenu/VBoxContainer/GridContainer/host_input
@onready var port_input: LineEdit = $BaseMenu/VBoxContainer/GridContainer/port_input
@onready var password_input: LineEdit = $BaseMenu/VBoxContainer/GridContainer/password_input

@onready var connect_status: Label = $BaseMenu/VBoxContainer/GridContainer/connect_status

# Called when the node enters the scene tree for the first time.
func _ready():
	ApClient = $"/root/ModLoader/asdfwyay-APBuckshot/ApClient"
	print(ApClient)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	match ApClient.connectionState:
		ApClient.ConnectionState.DISCONNECTED:
			connect_status.text = "NOT CONNECTED"
		ApClient.ConnectionState.CONNECTING:
			connect_status.text = "CONNECTING..."
		ApClient.ConnectionState.CONNECTED:
			connect_status.text = "CONNECTED"

func _on_connect_button_pressed():
	var slot: String = slot_input.text
	var hostname: String = host_input.text
	var port: String = port_input.text
	var password: String = password_input.text
	
	ApClient.APConnect(slot, hostname, port, password)

func _on_close_button_pressed():
	queue_free()
