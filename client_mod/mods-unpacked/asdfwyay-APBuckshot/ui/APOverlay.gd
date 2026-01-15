extends Node2D

var ApClient

signal update_transparency(id: float, a: float)

@onready var bg: ColorRect = $OuterContainer/Background
@onready var connect_status: Label = $OuterContainer/InnerContainer/connect_status
@onready var tracker: Control = $Tracker
@onready var tracker_label: MarginContainer = $Tracker/TrackerLabelContainer

@onready var item_name: Label = $Tracker/TrackerLabelContainer/VBoxContainer/item_name
@onready var item_status: Label = $Tracker/TrackerLabelContainer/VBoxContainer/item_status
@onready var item_model: TextureRect = $Tracker/TrackerLabelContainer/VBoxContainer/ItemModelBG/ItemModel

var tracker_visible: bool = false
var prev_mouse_mode

# Called when the node enters the scene tree for the first time.
func _ready():
	ApClient = $"/root/ModLoader/asdfwyay-APBuckshot/ApClient"
	print(ApClient)
	tracker.visible = false
	tracker_label.visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	tracker.visible = tracker_visible
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
					disable_dialogue_ui(dialogue_ui)
					prev_mouse_mode = Input.mouse_mode
					Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
				else:
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
		
	tracker_label.visible = true

func _on_hide_tracker_info():
	tracker_label.visible = false

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
