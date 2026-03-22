extends Node

const APCLIENT_PATH = "/root/ModLoader/asdfwyay-ArchipelagoClient/ApClient"
const APOVERLAY_PATH = "res://mods-unpacked/asdfwyay-ArchipelagoClient/ui/APOverlay.tscn"
const APCONNECT_PATH = "res://mods-unpacked/asdfwyay-ArchipelagoClient/ui/APConnectUI.tscn"
const MAINSCRN_PATH = "../../Camera/dialogue UI/menu ui/main screen"
const MP_BUTTON_PATH = MAINSCRN_PATH + "/button_multiplayer"
const TRUE_MP_BUTTON_PATH = MAINSCRN_PATH + "/true button_multiplayer"
const TRUE_OPTIONS_BUTTON_PATH = MAINSCRN_PATH + "/true button_options"

var APConnectScene
var APConnectInst
var APOverlayScene
var APOverlayInst

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
	ApClient.streak = 0
