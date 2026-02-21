extends Node


func BeginEnding(chain: ModLoaderHookChain):
	var mainNode := chain.reference_object as EndingManager
	var ApClient = mainNode.get_tree().root.get_node("/root/ModLoader/asdfwyay-APBuckshot/ApClient")
	
	if mainNode.get_tree().get_root().has_node("APOverlay"):
		mainNode.get_tree().get_root().get_node("APOverlay").queue_free()
		
	chain.execute_next()
	
	if (mainNode.roundManager.endless && mainNode.roundManager.endscore >= ApClient.goalAmt):
		ApClient.SendLocation(ApClient.L_CASH_OUT)
