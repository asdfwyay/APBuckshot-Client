extends Node2D

signal update_transparency(id: float, a: float)
signal update_bg_color(id: float, ch: String, val: float)

var ApClient
var tracker_visible: bool = false
var prev_mouse_mode
var current_msgs: Array = []

@onready var bg: ColorRect = $OuterContainer/Background
@onready var connect_status: Label = $OuterContainer/InnerContainer/connect_status
@onready var tracker: Control = $Tracker
@onready var tracker_label: MarginContainer = $Tracker/TrackerLabelContainer
@onready var tracker_text_client: MarginContainer = $Tracker/ChatWindowContainer
@onready var luck_level: Label = $Tracker/LuckContainer/luck_level
@onready var chat_log: RichTextLabel = $Tracker/ChatWindowContainer/VBoxContainer/PanelContainer/chat_log
@onready var chat_input: LineEdit = $Tracker/ChatWindowContainer/VBoxContainer/HBoxContainer/text_client_input
@onready var chat_send: Button = $Tracker/ChatWindowContainer/VBoxContainer/HBoxContainer/send_msg
@onready var life_bank: Control = $LifeBankCanvas/LifeBank
@onready var item_name: Label = $Tracker/TrackerLabelContainer/VBoxContainer/item_name
@onready var item_status: Label = $Tracker/TrackerLabelContainer/VBoxContainer/item_status
@onready var item_model: TextureRect = $Tracker/TrackerLabelContainer/VBoxContainer/ItemModelBG/ItemModel
@onready var stolen_indicator: SubViewportContainer = $TrapIndicators/OuterIndicatorContainer/HBoxContainer/StolenIndicator
@onready var schrodinger_indicator: SubViewportContainer = $TrapIndicators/OuterIndicatorContainer/HBoxContainer/SchrodingerIndicator/IndicatorVPContainer
@onready var deathlink_indicator: TextureRect = $TrapIndicators/OuterIndicatorContainer/HBoxContainer/DeathLinkIndicator
@onready var life_bank_canvas: CanvasLayer = $LifeBankCanvas
@onready var charge_count_canvas: CanvasLayer = $LifeBankCanvas/LifeBank/LifeBankContainer/Icon/ChargeCountCanvas
@onready var notification_player: AudioStreamPlayer = $Notifications/NotificationPlayer
@onready var notification_container: VBoxContainer = $Notifications/NotificationMarginContainer/NotificationContainer
@onready var item_buff_canvas: CanvasLayer = $ItemBuffCanvas
@onready var beer_ui: Control = $ItemBuffCanvas/ItemBuffs/Beer
@onready var mag_ui: Control = $ItemBuffCanvas/ItemBuffs/MagnifyingGlass
@onready var phone_ui: Control = $ItemBuffCanvas/ItemBuffs/BurnerPhone
@onready var phone_hbox: HBoxContainer = $ItemBuffCanvas/ItemBuffs/BurnerPhone/PhoneChoiceUI/VBoxContainer/HBoxContainer
@onready var poison: Label = $AdditionalInfo/MarginContainer/ColorRect/MarginContainer/VBoxContainer/HBoxContainerPoison/poison_count
@onready var streak: Label = $AdditionalInfo/MarginContainer/ColorRect/MarginContainer/VBoxContainer/HBoxContainerStreak/streak_count

func _ready():
	ApClient = $"/root/ModLoader/asdfwyay-APBuckshot/ApClient"
	print(ApClient)
	ApClient.send_notification.connect(_on_receive_notification)
	ApClient.send_chat.connect(_on_receive_chat)
	ApClient.request_beer_choice.connect(_on_request_beer_choice)
	ApClient.request_mag_choice.connect(_on_request_mag_choice)
	ApClient.request_phone_choice.connect(_on_request_phone_choice)
	
	tracker.visible = false
	tracker_label.visible = false
	tracker_text_client.visible = true
	
	stolen_indicator.visible = false
	schrodinger_indicator.visible = false
	deathlink_indicator.visible = false
	
	life_bank_canvas.visible = true
	charge_count_canvas.visible = true
	item_buff_canvas.visible = false
	
	beer_ui.visible = false
	mag_ui.visible = false
	phone_ui.visible = false
	
	stolen_indicator.position = Vector2(80, 0)
	
	var stolen_indicator_overlay = stolen_indicator.get_node("TextureOverlay")
	stolen_indicator_overlay.texture = load("res://misc/cursor xp_invalid.png")
	stolen_indicator_overlay.scale = Vector2(0.73, 0.73)
	stolen_indicator_overlay.position = Vector2(21.49, 2.51)
	stolen_indicator.get_node("IndicatorVP").add_child(
		load("res://instances/item_magnifying glass.tscn").instantiate()
	)
	
	deathlink_indicator.texture = load("res://misc/defib charge_skull png.png")


func _process(delta):
	tracker.visible = tracker_visible
	life_bank.visible = !tracker.visible
	
	if ApClient.mechanicItems.has(ApClient.I_LIFE_BANK):
		life_bank.visible = life_bank.visible and ApClient.mechanicItems[ApClient.I_LIFE_BANK] > 0
	
	stolen_indicator.visible = ApClient.I_ITEM_TRAP in ApClient.trapQueue
	schrodinger_indicator.visible = ApClient.I_BULLET_TRAP in ApClient.trapQueue
	deathlink_indicator.visible = ApClient.awaitingDeathLink
	
	poison.text = ApClient.poison
	streak.text = ApClient.streak
	
	match ApClient.connectionState:
		ApClient.ConnectionState.DISCONNECTED:
			connect_status.text = "AP DISCONNECTED"
			connect_status.set("theme_override_colors/font_color", Color8(204, 51, 0))
		ApClient.ConnectionState.CONNECTING:
			connect_status.text = "ATTEMPTING TO RECONNECT TO AP..."
			connect_status.set("theme_override_colors/font_color", Color8(255, 204, 0))
		ApClient.ConnectionState.CONNECTED:
			connect_status.text = "AP CONNECTED"
			connect_status.set("theme_override_colors/font_color", Color8(255, 255, 255))


func _on_connect_status_resized():
	if (connect_status and bg):
		var bg_size = connect_status.get_rect().size
		
		bg_size.x += 10
		bg_size.y += 10
		
		bg.set_size(bg_size, true)


func _input(event):
	if event is InputEventKey:
		if event.pressed and not event.echo:
			if event.keycode == KEY_TAB:
				tracker_visible = !tracker_visible
				
				var dialogue_ui = get_tree().root.get_node("main/Camera/dialogue UI")

				if (tracker_visible):
					for id in ApClient.obtainedItems:
						update_transparency.emit(id, 0)
					
					for id in range(ApClient.I_OFST_ITEM_BUFF, ApClient.I_OFST_ITEM_BUFF + 9):
						var item_id = id - ApClient.I_OFST_ITEM_BUFF + 2
						var g = 0.0
						if ApClient.mechanicItems[id] > 0:
							g = 0.125
						update_bg_color.emit(item_id, "g", g)
					for id in range(ApClient.I_OFST_ITEM_DEBUFF, ApClient.I_OFST_ITEM_DEBUFF + 9):
						var item_id = id - ApClient.I_OFST_ITEM_DEBUFF + 2
						var r = 0.0
						if item_id in ApClient.included_item_debuffs and ApClient.mechanicItems[id] == 0:
							r = 0.15
						update_bg_color.emit(item_id, "r", r)
					
					if dialogue_ui:
						disable_dialogue_ui(dialogue_ui)
					prev_mouse_mode = Input.mouse_mode
					Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
					update_luck_level()
				else:
					if dialogue_ui:
						enable_dialogue_ui(dialogue_ui)
					Input.mouse_mode = prev_mouse_mode


func _on_show_tracker_info(id: int, name: String, vp: SubViewport):
	if not tracker_visible:
		return
	
	item_name.text = name
	if ApClient.mechanicItems[id + ApClient.I_OFST_ITEM_BUFF - 2] > 0:
		item_name.text += " ↑"
	if (
		id in ApClient.included_item_debuffs
		and ApClient.mechanicItems[id + ApClient.I_OFST_ITEM_DEBUFF - 2] == 0
	):
		item_name.text += " ↓"
		
	if float(id) in ApClient.obtainedItems:
		item_status.text = "FOUND"
		item_status.set("theme_override_colors/font_color", Color8(0, 255, 0))
	else:
		item_status.text = "NOT FOUND"
		item_status.set("theme_override_colors/font_color", Color8(204, 51, 0))
	
	if item_model.texture is ViewportTexture:
		item_model.texture.set_viewport_path_in_scene(vp.get_path())
		
	tracker_text_client.visible = false
	tracker_label.visible = true


func _on_hide_tracker_info():
	update_luck_level()
	
	tracker_label.visible = false
	tracker_text_client.visible = true


func update_luck_level():
	if (ApClient.mechanicItems.has(ApClient.I_ITEM_LUCK)):
		match (ApClient.mechanicItems[ApClient.I_ITEM_LUCK]):
			0:
				luck_level.text = ""
				luck_level.set("theme_override_colors/font_color", Color8(204, 51, 0))
			1:
				luck_level.text = "♣"
				luck_level.set("theme_override_colors/font_color", Color8(176, 141, 87))
			2:
				luck_level.text = "♣♣"
				luck_level.set("theme_override_colors/font_color", Color8(192, 192, 192))
			_:
				luck_level.text = "♣♣♣"
				item_status.set("theme_override_colors/font_color", Color8(255, 215, 0))
	else:
		luck_level.text = "NONE"
		luck_level.set("theme_override_colors/font_color", Color8(204, 51, 0))


func disable_dialogue_ui(dialogue_ui: Node):
	for child in dialogue_ui.get_children():
		child.mouse_filter = Control.MOUSE_FILTER_IGNORE


func enable_dialogue_ui(dialogue_ui: Node):
	for child in dialogue_ui.get_children():
		if child is Label:
			continue
		elif child is TextureRect:
			child.mouse_filter = Control.MOUSE_FILTER_PASS
		elif child is Control:
			child.mouse_filter = Control.MOUSE_FILTER_STOP


func _on_receive_notification(msg):
	if current_msgs.size() >= 6:
		var oldest_msg = current_msgs.pop_front()
		if is_instance_valid(oldest_msg):
			oldest_msg.queue_free()
	
	var msg_label = Label.new()
	var custom_font = load("res://fonts/fake receipt.otf")
	
	msg_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	msg_label.custom_minimum_size.x = 540
	msg_label.add_theme_font_override("font", custom_font)
	msg_label.text = msg
	msg_label.modulate.a = 1.0 - 0.1*current_msgs.size()
	
	notification_container.add_child(msg_label)
	current_msgs.append(msg_label)
	notification_player.play()
	await get_tree().create_timer(4.0).timeout
	
	if is_instance_valid(msg_label):
		var tween = create_tween()
		tween.tween_property(msg_label, "modulate:a", 0.0, 1.0)
		await get_tree().create_timer(1.0).timeout
	
	if current_msgs:
		var oldest_msg = current_msgs.pop_front()
		if is_instance_valid(oldest_msg):
			oldest_msg.queue_free()


func _on_receive_chat(msg):
	chat_log.append_text(msg)


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
		if event.pressed and event.keycode == KEY_ENTER:
			_on_send_msg_pressed()


func _on_text_client_input_gui_input(event):
	_handle_control_keys(event, chat_input)


func _on_send_msg_pressed():
	if not chat_input.text:
		return
	
	var chatPck = ApClient.Say.new(chat_input.text)
	ApClient.SendPacket(chatPck)
	
	chat_input.text = ""


func _on_request_beer_choice():
	item_buff_canvas.visible = true
	beer_ui.visible = true


func _on_request_mag_choice():
	item_buff_canvas.visible = true
	mag_ui.visible = true


func _on_beer_yes_gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			item_buff_canvas.visible = false
			beer_ui.visible = false
			ApClient.send_beer_choice.emit(true)


func _on_beer_no_gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			item_buff_canvas.visible = false
			beer_ui.visible = false
			ApClient.send_beer_choice.emit(false)


func _on_mag_live_gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			item_buff_canvas.visible = false
			mag_ui.visible = false
			ApClient.send_mag_choice.emit("live")


func _on_mag_blank_gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			item_buff_canvas.visible = false
			mag_ui.visible = false
			ApClient.send_mag_choice.emit("blank")


func _on_mag_nothing_gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			item_buff_canvas.visible = false
			mag_ui.visible = false
			ApClient.send_mag_choice.emit("none")


func _on_request_phone_choice(num_shells: int):
	var num_options = min(num_shells - 1, 6)
	for i in range(num_options):
		var bg: ColorRect = ColorRect.new()
		bg.color = Color("#0000007f")
		bg.custom_minimum_size = Vector2(30, 40)
		bg.gui_input.connect(func(event): 
			if event is InputEventMouseButton and event.pressed:
				if event.button_index == MOUSE_BUTTON_LEFT:
					item_buff_canvas.visible = false
					phone_ui.visible = false
					ApClient.send_phone_choice.emit(i + 2)
					
					for child in phone_hbox.get_children(true):
						child.queue_free()
		)
		
		var label: Label = Label.new()
		label.text = str(i + 2)
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		label.add_theme_font_override("font", load("res://fonts/fake receipt.otf"))
		
		bg.add_child(label)
		phone_hbox.add_child(bg)
	
	if num_options > 0:
		item_buff_canvas.visible = true
		phone_ui.visible = true
