extends Node

const APCLIENT_PATH = "/root/ModLoader/asdfwyay-APBuckshot/ApClient"


func Shoot(chain: ModLoaderHookChain, who : String):
	var mainNode := chain.reference_object as ShotgunShooting
	var ApClient = mainNode.get_tree().root.get_node(APCLIENT_PATH)
	
	ApClient.isPlayerTurn = false
	
	if ApClient.I_BULLET_TRAP in ApClient.trapQueue:
		var new_bullet_idx = randi_range(0, 1)
		if (new_bullet_idx):
			mainNode.roundManager.shellSpawner.sequenceArray[0] = "blank"
		else:
			mainNode.roundManager.shellSpawner.sequenceArray[0] = "live"
		ApClient.trapQueue.erase(ApClient.I_BULLET_TRAP)
	
	if (
		mainNode.shellSpawner.sequenceArray[0] == "live"  and who == "dealer"
		or mainNode.shellSpawner.sequenceArray[0] == "blank" and who == "self"
	):
		ApClient.shotsanityCount += 1
		if ApClient.shotsanityCount <= 1000:
			ApClient.SendLocation(
				ApClient.L_OFST_SS + ApClient.shotsanityCount - 1
			)
	
	chain.execute_next_async([who])
