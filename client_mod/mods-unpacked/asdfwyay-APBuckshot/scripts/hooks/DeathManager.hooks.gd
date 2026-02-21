extends Node


func MainDeathRoutine(chain: ModLoaderHookChain):
	var mainNode := chain.reference_object as DeathManager
	var ApClient = mainNode.get_tree().root.get_node("/root/ModLoader/asdfwyay-APBuckshot/ApClient")
	
	chain.execute_next_async()
	
	if ApClient.deathLink and !ApClient.awaitingDeathLink:
		ApClient.sendDeathLink()
	if ApClient.mechanicItems.has(ApClient.I_LIFE_BANK):
		ApClient.lifeBankCharges = ApClient.mechanicItems[ApClient.I_LIFE_BANK]
	ApClient.awaitingDeathLink = false
