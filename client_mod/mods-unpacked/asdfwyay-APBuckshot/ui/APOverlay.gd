extends Node2D

var ApClient

@onready var bg: ColorRect = $OuterContainer/Background
@onready var connect_status: Label = $OuterContainer/InnerContainer/connect_status

# Called when the node enters the scene tree for the first time.
func _ready():
	ApClient = $"/root/ModLoader/asdfwyay-APBuckshot/ApClient"
	print(ApClient)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
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
