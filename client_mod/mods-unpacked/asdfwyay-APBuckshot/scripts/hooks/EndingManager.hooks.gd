extends Node


func BeginEnding(chain: ModLoaderHookChain):
	var mainNode := chain.reference_object as EndingManager
	var ApClient = mainNode.get_tree().root.get_node("/root/ModLoader/asdfwyay-APBuckshot/ApClient")
	var slot_num = ApClient.slot_num
	
	if mainNode.get_tree().get_root().has_node("APOverlay"):
		mainNode.get_tree().get_root().get_node("APOverlay").queue_free()
	
	if mainNode.roundManager.endless:
		if ApClient.async_points:
			if ApClient.async_point_total + mainNode.roundManager.endscore >= ApClient.goalAmt:
				ApClient.SendLocation(ApClient.L_CASH_OUT)
			
			var setPck = ApClient.Set.new(
				"BuckshotRoulettePoints_%d" % ApClient.slot_num,
				0,
				true,
				[
					{"operation": "default", "value": 0},
					{"operation": "add", "value": mainNode.roundManager.endscore},
				]
			)
			ApClient.SendPacket(setPck)
		elif mainNode.roundManager.endscore >= ApClient.goalAmt:
			ApClient.SendLocation(ApClient.L_CASH_OUT)
	
	await chain.execute_next_async()
