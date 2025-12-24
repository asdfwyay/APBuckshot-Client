extends Node

func Shoot(chain: ModLoaderHookChain, who : String):
	var mainNode := chain.reference_object as ShotgunShooting
	var ApClient = mainNode.get_tree().root.get_node("/root/ModLoader/asdfwyay-APBuckshot/ApClient")
	
	if (mainNode.shellSpawner.sequenceArray[0] == "live" && who == "dealer"):
		ApClient.shotsanityLiveCount += 1
		if ApClient.shotsanityLiveCount <= 500:
			ApClient.SendLocation(57 + ApClient.shotsanityLiveCount)
	if (mainNode.shellSpawner.sequenceArray[0] == "blank" && who == "self"):
		ApClient.shotsanityBlankCount += 1
		if ApClient.shotsanityBlankCount <= 500:
			ApClient.SendLocation(557 + ApClient.shotsanityBlankCount)
			
	chain.execute_next_async([who])
