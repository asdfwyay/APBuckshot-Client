extends Node

const APCLIENT_PATH = "/root/ModLoader/asdfwyay-APBuckshot/ApClient"

func GetFlip(chain: ModLoaderHookChain):
	var mainNode := chain.reference_object as Medicine
	var ApClient = mainNode.get_tree().root.get_node(APCLIENT_PATH)
	
	var value = randf_range(0.0, 1.0)
	var comp = 0.833 if ApClient.mechanicItems[ApClient.I_OFST_ITEM_BUFF + 5] else 0.5
	if (value < comp):
		return false
	else:
		if (
			7 in ApClient.included_item_debuffs
			and ApClient.mechanicItems[ApClient.I_OFST_ITEM_DEBUFF + 5] == 0
		):
			ApClient.poison += 20
		return true
