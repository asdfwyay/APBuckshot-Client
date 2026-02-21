extends Node2D

signal update_transparency(id: float, a: float)

var ApClient
var tracker_visible: bool = false
var prev_mouse_mode
var current_msgs: Array = []

@onready var bg: ColorRect = $OuterContainer/Background
@onready var connect_status: Label = $OuterContainer/InnerContainer/connect_status
@onready var tracker: Control = $Tracker
@onready var tracker_label: MarginContainer = $Tracker/TrackerLabelContainer
@onready var tracker_added: MarginContainer = $Tracker/TrackerAdditionalInfoContainer
@onready var life_bank: Control = $LifeBankCanvas/LifeBank
@onready var item_name: Label = $Tracker/TrackerLabelContainer/VBoxContainer/item_name
@onready var item_status: Label = $Tracker/TrackerLabelContainer/VBoxContainer/item_status
@onready var item_model: TextureRect = $Tracker/TrackerLabelContainer/VBoxContainer/ItemModelBG/ItemModel
@onready var luck_level: Label = $Tracker/TrackerAdditionalInfoContainer/VBoxContainer/HBoxContainer/luck_level
@onready var stolen_indicator: SubViewportContainer = $TrapIndicators/OuterIndicatorContainer/HBoxContainer/StolenIndicator
@onready var schrodinger_indicator: SubViewportContainer = $TrapIndicators/OuterIndicatorContainer/HBoxContainer/SchrodingerIndicator/IndicatorVPContainer
@onready var deathlink_indicator: TextureRect = $TrapIndicators/OuterIndicatorContainer/HBoxContainer/DeathLinkIndicator
@onready var life_bank_canvas: CanvasLayer = $LifeBankCanvas
@onready var charge_count_canvas: CanvasLayer = $LifeBankCanvas/LifeBank/LifeBankContainer/Icon/ChargeCountCanvas
@onready var notification_player: AudioStreamPlayer = $Notifications/NotificationPlayer
@onready var notification_container: VBoxContainer = $Notifications/NotificationMarginContainer/NotificationContainer


func _ready():
	ApClient = $"/root/ModLoader/asdfwyay-APBuckshot/ApClient"
	print(ApClient)
	ApClient.send_notification.connect(_on_receive_notification)
	
	tracker.visible = false
	tracker_label.visible = false
	tracker_added.visible = true
	
	stolen_indicator.visible = false
	schrodinger_indicator.visible = false
	deathlink_indicator.visible = false
	
	life_bank_canvas.visible = true
	charge_count_canvas.visible = true
	
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
					if dialogue_ui:
						disable_dialogue_ui(dialogue_ui)
					prev_mouse_mode = Input.mouse_mode
					Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
					update_additional_info()
				else:
					if dialogue_ui:
						enable_dialogue_ui(dialogue_ui)
					Input.mouse_mode = prev_mouse_mode


func _on_show_tracker_info(id: int, name: String, vp: SubViewport):
	if not tracker_visible:
		return
	
	item_name.text = name
	
	if float(id) in ApClient.obtainedItems:
		item_status.text = "FOUND"
		item_status.set("theme_override_colors/font_color", Color8(0, 255, 0))
	else:
		item_status.text = "NOT FOUND"
		item_status.set("theme_override_colors/font_color", Color8(204, 51, 0))
	
	if item_model.texture is ViewportTexture:
		item_model.texture.set_viewport_path_in_scene(vp.get_path())
		
	tracker_added.visible = false
	tracker_label.visible = true


func _on_hide_tracker_info():
	update_additional_info()
	
	tracker_label.visible = false
	tracker_added.visible = true


func update_additional_info():
	if (ApClient.mechanicItems.has(ApClient.I_ITEM_LUCK)):
		match (ApClient.mechanicItems[ApClient.I_ITEM_LUCK]):
			0:
				luck_level.text = "NONE"
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
