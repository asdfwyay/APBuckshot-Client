extends Node

var APConnectScene
var APConnectInst

func Intro(chain: ModLoaderHookChain):
	var mainNode := chain.reference_object as MenuManager
	var mp_button = mainNode.get_node("../../Camera/dialogue UI/menu ui/main screen/button_multiplayer")
	mp_button.text = "ARCHIPELAGO"
	chain.execute_next()
	
func StartMultiplayer(chain: ModLoaderHookChain):
	var mainNode := chain.reference_object as MenuManager
	
	if is_instance_valid(APConnectInst):
		APConnectInst.queue_free()
	else:
		APConnectScene = load("res://mods-unpacked/asdfwyay-APBuckshot/ui/APConnectUI.tscn")
		APConnectInst = APConnectScene.instantiate()
		mainNode.get_tree().root.add_child(APConnectInst)
	mainNode.ResetButtons()
