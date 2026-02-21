extends Node

const APCLIENT_PATH = "/root/ModLoader/asdfwyay-APBuckshot/ApClient"
const APOVERLAY_PATH = "res://mods-unpacked/asdfwyay-APBuckshot/ui/APOverlay.tscn"
const APCONNECT_PATH = "res://mods-unpacked/asdfwyay-APBuckshot/ui/APConnectUI.tscn"
const MAINSCRN_PATH = "../../Camera/dialogue UI/menu ui/main screen"
const MP_BUTTON_PATH = MAINSCRN_PATH + "/button_multiplayer"
const TRUE_MP_BUTTON_PATH = MAINSCRN_PATH + "/true button_multiplayer"
const TRUE_OPTIONS_BUTTON_PATH = MAINSCRN_PATH + "/true button_options"

var APConnectScene
var APConnectInst
var APOverlayScene
var APOverlayInst


func Intro(chain: ModLoaderHookChain):
	var mainNode := chain.reference_object as MenuManager
	
	var main_scrn = mainNode.get_node(MAINSCRN_PATH)
	for child in main_scrn.get_children():
		if (
			(child is Label or child is Button)
			and (
				child.name.ends_with("_options")
				or child.name.ends_with("_credits")
				or child.name.ends_with("_exit")
			)
		):
			child.position.y += 28 if child.name.begins_with("true") else 25
	
	var mp_button: Label = mainNode.get_node(MP_BUTTON_PATH)
	var true_mp_button: Button = mainNode.get_node(TRUE_MP_BUTTON_PATH)
	var true_options_button: Button = mainNode.get_node(TRUE_OPTIONS_BUTTON_PATH)
	
	var ap_button = mp_button.duplicate()
	ap_button.name = "button_archipelago"
	ap_button.text = "ARCHIPELAGO"
	ap_button.position.y += 25
	
	var true_ap_button = true_mp_button.duplicate()
	true_ap_button.name = "true button_archipelago"
	true_ap_button.position.y += 28
	true_ap_button.focus_neighbor_top = "../true button_multiplayer"
	true_ap_button.focus_neighbor_bottom = "../true button_options"
	
	var true_ap_button_script = true_ap_button.get_child(0)
	true_ap_button_script.name = "button class_archipelago"
	true_ap_button_script.alias = "start archipelago"
	true_ap_button_script.ui = ap_button
	true_ap_button_script.connect("is_pressed", func():
		if is_instance_valid(APConnectInst):
			APConnectInst.queue_free()
		else:
			APConnectScene = load(APCONNECT_PATH)
			APConnectInst = APConnectScene.instantiate()
			mainNode.get_tree().root.add_child(APConnectInst)
		mainNode.ResetButtons()
	)
	
	main_scrn.add_child(ap_button)
	main_scrn.add_child(true_ap_button)
	
	true_mp_button.focus_neighbor_bottom = "../" + true_ap_button.name
	true_options_button.focus_neighbor_top = "../" + true_ap_button.name
	
	chain.execute_next()
	
	var ap_version = Label.new()
	
	ap_version.name = "ap_version"
	ap_version.text = "v0.1.2 (APBuckshot)"
	ap_version.position = Vector2(19, 500)
	
	var f = load("res://fonts/fake receipt.otf")
	ap_version.add_theme_font_override("font", f)
	ap_version.add_theme_font_size_override("font_size", 12)
	ap_version.add_theme_color_override("font_color", Color.DARK_GRAY)
	ap_version.add_theme_color_override("font_shadow_color", Color.BLACK)
	
	mainNode.version.get_parent().add_child(ap_version)


func Start(chain: ModLoaderHookChain):
	var mainNode := chain.reference_object as MenuManager
	var ApClient = mainNode.get_tree().root.get_node(APCLIENT_PATH)
	await chain.execute_next_async()
	
	APOverlayScene = load(APOVERLAY_PATH)
	APOverlayInst = APOverlayScene.instantiate()
	mainNode.get_tree().get_root().add_child(APOverlayInst)
	
	if ApClient.mechanicItems.has(ApClient.I_LIFE_BANK):
		ApClient.lifeBankCharges = ApClient.mechanicItems[ApClient.I_LIFE_BANK]
	ApClient.isPlayerTurn = false
