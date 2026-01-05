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
	
func Start(chain: ModLoaderHookChain):
	var mainNode := chain.reference_object as MenuManager
	await chain.execute_next_async()
	
	APOverlayScene = load("res://mods-unpacked/asdfwyay-APBuckshot/ui/APOverlay.tscn")
	APOverlayInst = APOverlayScene.instantiate()
	mainNode.get_tree().get_root().add_child(APOverlayInst)
	
func StartMultiplayer(chain: ModLoaderHookChain):
	var mainNode := chain.reference_object as MenuManager
	
	if is_instance_valid(APConnectInst):
		APConnectInst.queue_free()
	else:
		APConnectScene = load("res://mods-unpacked/asdfwyay-APBuckshot/ui/APConnectUI.tscn")
		APConnectInst = APConnectScene.instantiate()
		mainNode.get_tree().root.add_child(APConnectInst)
	mainNode.ResetButtons()
