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
	
	if (
		ApClient.checkItemDebuff(2)
		and ApClient.hasUsedHandsaw
		and who == "player"
	):
		mainNode.roundManager.currentShotgunDamage += 1
	
	var lastShell = mainNode.shellSpawner.sequenceArray[0]
	await chain.execute_next_async([who])
	if lastShell == "live" and who == "player":
		ApClient.streak = 0
	
	mainNode.roundManager.currentShotgunDamage = 1


func DealerCheckHandCuffs(chain: ModLoaderHookChain):
	var mainNode := chain.reference_object as DealerIntelligence
	var ApClient = mainNode.get_tree().root.get_node(APCLIENT_PATH)
	
	if ApClient.checkItemDebuff(6) and randf() <= 0.25:
		mainNode.dealerAboutToBreakFree = true
	
	await chain.execute_next_async()
	
	if ApClient.item_buff_states["handcuffs"]:
		mainNode.dealerAboutToBreakFree = false
		ApClient.item_buff_states["handcuffs"] = false
