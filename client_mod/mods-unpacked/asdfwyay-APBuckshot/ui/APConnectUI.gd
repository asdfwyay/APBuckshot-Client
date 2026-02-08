extends Node

var ApClient

@onready var slot_input: LineEdit = $BaseMenu/VBoxContainer/GridContainer/slot_input
@onready var host_input: LineEdit = $BaseMenu/VBoxContainer/GridContainer/host_input
@onready var port_input: LineEdit = $BaseMenu/VBoxContainer/GridContainer/port_input
@onready var password_input: LineEdit = $BaseMenu/VBoxContainer/GridContainer/password_input
@onready var deathlink_cb: CheckButton = $BaseMenu/VBoxContainer/GridContainer/deathlink_cb

@onready var connect_status: Label = $BaseMenu/VBoxContainer/GridContainer/connect_status

# Called when the node enters the scene tree for the first time.
func _ready():
	ApClient = $"/root/ModLoader/asdfwyay-APBuckshot/ApClient"
	print(ApClient)
	
	slot_input.text = ApClient.slot
	host_input.text = ApClient.hostname
	port_input.text = ApClient.port
	password_input.text = ApClient.password
	
	deathlink_cb.set_pressed_no_signal(ApClient.deathLink)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	match ApClient.connectionState:
		ApClient.ConnectionState.DISCONNECTED:
			connect_status.text = "NOT CONNECTED"
		ApClient.ConnectionState.CONNECTING:
			connect_status.text = "CONNECTING..."
		ApClient.ConnectionState.CONNECTED:
			connect_status.text = "CONNECTED"
			

func remove_char_at_index(in_str: String, i: int) -> String:
	if i < 0 or i >= in_str.length():
		return in_str
	return in_str.substr(0, i) + in_str.substr(i + 1, in_str.length() - i - 1)
	
func remove_substr_at_indices(in_str: String, start: int, end: int) -> String:
	if start >= in_str.length() or end < 0 or end < start:
		return in_str
		
	start = max(0, start)
	end = min(in_str.length() - 1, end)
	
	return in_str.substr(0, start) + in_str.substr(end + 1, in_str.length() - end - 1)

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
			var caret_column
			
			if input_field.get_selected_text():
				caret_column = input_field.get_selection_from_column()
				input_field.text = remove_substr_at_indices(
					input_field.text,
					input_field.get_selection_from_column(),
					input_field.get_selection_to_column() - 1
				)
				input_field.caret_column = caret_column
			elif (input_field.text).length() > 0:
				caret_column = input_field.caret_column
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

func _on_deathlink_cb_toggled(button_pressed):
	ApClient.setDeathLink(deathlink_cb.button_pressed)
