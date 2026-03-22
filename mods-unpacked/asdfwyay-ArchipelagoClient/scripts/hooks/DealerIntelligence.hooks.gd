extends Node

const APCLIENT_PATH = "/root/ModLoader/asdfwyay-ArchipelagoClient/ApClient"


func Shoot(chain: ModLoaderHookChain, who : String):
	var mainNode := chain.reference_object as DealerIntelligence
	var ApClient = mainNode.get_tree().root.get_node(APCLIENT_PATH)
	
	if mainNode.shellSpawner.sequenceArray[0] == "live" and who == "player":
		ApClient.streak = 0
	
	chain.execute_next_async([who])
