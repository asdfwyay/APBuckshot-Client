extends Node

func UnlockRoutine(chain: ModLoaderHookChain) -> void:
	var mainNode := chain.reference_object as Unlocker
	var ApClient = mainNode.get_tree().root.get_node("/root/ModLoader/asdfwyay-APBuckshot/ApClient")
	
	if ApClient.canAccessDON:
		chain.execute_next()
