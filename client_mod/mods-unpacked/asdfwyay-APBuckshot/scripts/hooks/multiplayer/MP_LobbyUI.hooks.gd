extends Node

const APCLIENT_PATH = "/root/ModLoader/asdfwyay-APBuckshot/ApClient"

func CheckLobbyCopyPaste(chain: ModLoaderHookChain):
	var mainNode := chain.reference_object as MP_LobbyUI
	var ApClient = mainNode.get_tree().root.get_node(APCLIENT_PATH)
	
	chain.execute_next()

	if ApClient.connectionState == ApClient.ConnectionState.CONNECTED:
		mainNode.ui_invite_friends.visible = false
