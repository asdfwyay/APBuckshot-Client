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
			

func remove_char_at_index(in_str: String, i: int)-> String:
	if i < 0 or i >= in_str.length():
		return in_str
	return in_str.substr(0, i) + in_str.substr(i + 1, in_str.length() - i - 1)

func _handle_control_keys(event, input_field: LineEdit):
	if event is InputEventKey:
		if event.pressed and event.keycode == KEY_LEFT:
			input_field.caret_column = max(0, input_field.caret_column - 1)
		if event.pressed and event.keycode == KEY_RIGHT:
			input_field.caret_column = min(
				input_field.text.length(),
				input_field.caret_column + 1
			)
		if event.pressed and event.keycode == KEY_BACKSPACE:
			var caret_column = input_field.caret_column
			
			if (input_field.text).length() > 0:
				input_field.text = remove_char_at_index(
					input_field.text,
					caret_column - 1
				)
				
			input_field.caret_column = caret_column - 1

func _on_slot_input_gui_input(event):
	_handle_control_keys(event, slot_input)
	
func _on_host_input_gui_input(event):
	_handle_control_keys(event, host_input)

func _on_port_input_gui_input(event):
	_handle_control_keys(event, port_input)

func _on_password_input_gui_input(event):
	_handle_control_keys(event, password_input)

func _on_connect_button_pressed():
	var slot: String = slot_input.text
	var hostname: String = host_input.text
	var port: String = port_input.text
	var password: String = password_input.text
	
	ApClient.APConnect(slot, hostname, port, password)

func _on_close_button_pressed():
	queue_free()
