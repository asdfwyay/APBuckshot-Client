extends Node

const APCLIENT_PATH = "/root/ModLoader/asdfwyay-APBuckshot/ApClient"

func Shoot(chain: ModLoaderHookChain, who : String):
	var mainNode := chain.reference_object as DealerIntelligence
	var ApClient = mainNode.get_tree().root.get_node(APCLIENT_PATH)
	
	# Schrodinger's Bullet Trap
	if ApClient.I_BULLET_TRAP in ApClient.dealerTrapQueue:
		var new_bullet_idx = randi_range(0, 1)
		if (new_bullet_idx):
			mainNode.shellSpawner.sequenceArray[0] = "blank"
		else:
			mainNode.shellSpawner.sequenceArray[0] = "live"
		ApClient.dealerTrapQueue.erase(ApClient.I_BULLET_TRAP)
		
	var lastShell = mainNode.shellSpawner.sequenceArray[0]
	await chain.execute_next_async([who])
	if lastShell == "live" and who == "player":
		ApClient.streak = 0


func DealerCheckHandCuffs(chain: ModLoaderHookChain):
	var mainNode := chain.reference_object as DealerIntelligence
	var ApClient = mainNode.get_tree().root.get_node(APCLIENT_PATH)
	
	if (
		6 in ApClient.included_item_debuffs
		and ApClient.mechanicItems[ApClient.I_OFST_ITEM_DEBUFF + 4] == 0
		and randf() <= 0.25
	):
		mainNode.dealerAboutToBreakFree = true
	
	await chain.execute_next_async()
	
	if ApClient.item_buff_states["handcuffs"]:
		mainNode.dealerAboutToBreakFree = false
		ApClient.item_buff_states["handcuffs"] = false
