extends Node

const APCLIENT_PATH = "/root/ModLoader/asdfwyay-APBuckshot/ApClient"

func CheckIfHovering(chain: ModLoaderHookChain):
	var mainNode := chain.reference_object as InteractionManager
	var ApClient = mainNode.get_tree().root.get_node(APCLIENT_PATH)
	
	if (
		mainNode.activeInteractionBranch.itemName == "adrenaline"
		and ApClient.mechanicItems[ApClient.I_OFST_ITEM_BUFF + 7] > 0
	):
		mainNode.activeInteractionBranch.interactionInvalid = false
	
	chain.execute_next()
