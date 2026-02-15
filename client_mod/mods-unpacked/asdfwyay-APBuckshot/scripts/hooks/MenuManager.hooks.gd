extends Node

var APConnectScene
var APConnectInst

var APOverlayScene
var APOverlayInst

func Intro(chain: ModLoaderHookChain):
	var mainNode := chain.reference_object as MenuManager
	var mp_button = mainNode.get_node("../../Camera/dialogue UI/menu ui/main screen/button_multiplayer")
	mp_button.text = "ARCHIPELAGO"
	
	chain.execute_next()
	
	var ap_version = Label.new()
	
	ap_version.text = "v0.1.1 (APBuckshot)"
	ap_version.position = Vector2(19, 500)
	
	var f = load("res://fonts/fake receipt.otf")
	ap_version.add_theme_font_override("font", f)
	ap_version.add_theme_font_size_override("font_size", 12)
	ap_version.add_theme_color_override("font_color", Color.DARK_GRAY)
	ap_version.add_theme_color_override("font_shadow_color", Color.BLACK)
	
	mainNode.version.get_parent().add_child(ap_version)
	
func Start(chain: ModLoaderHookChain):
	var mainNode := chain.reference_object as MenuManager
	var ApClient = mainNode.get_tree().root.get_node("/root/ModLoader/asdfwyay-APBuckshot/ApClient")
	await chain.execute_next_async()
	
	APOverlayScene = load("res://mods-unpacked/asdfwyay-APBuckshot/ui/APOverlay.tscn")
	APOverlayInst = APOverlayScene.instantiate()
	mainNode.get_tree().get_root().add_child(APOverlayInst)
	
	if ApClient.mechanicItems.has(ApClient.I_LIFE_BANK):
		ApClient.lifeBankCharges = ApClient.mechanicItems[ApClient.I_LIFE_BANK]
	ApClient.isPlayerTurn = false
	
func StartMultiplayer(chain: ModLoaderHookChain):
	var mainNode := chain.reference_object as MenuManager
	
	if is_instance_valid(APConnectInst):
		APConnectInst.queue_free()
	else:
		APConnectScene = load("res://mods-unpacked/asdfwyay-APBuckshot/ui/APConnectUI.tscn")
		APConnectInst = APConnectScene.instantiate()
		mainNode.get_tree().root.add_child(APConnectInst)
	mainNode.ResetButtons()
