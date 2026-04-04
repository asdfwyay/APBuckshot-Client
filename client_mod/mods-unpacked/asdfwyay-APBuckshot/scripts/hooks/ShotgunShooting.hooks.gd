extends Node

const APCLIENT_PATH = "/root/ModLoader/asdfwyay-APBuckshot/ApClient"


func Shoot(chain: ModLoaderHookChain, who : String):
	var mainNode := chain.reference_object as ShotgunShooting
	var ApClient = mainNode.get_tree().root.get_node(APCLIENT_PATH)
	
	ApClient.isPlayerTurn = false
	
	# Schrodinger's Bullet Trap
	if ApClient.I_BULLET_TRAP in ApClient.trapQueue:
		var new_bullet_idx = randi_range(0, 1)
		if (new_bullet_idx):
			mainNode.roundManager.shellSpawner.sequenceArray[0] = "blank"
		else:
			mainNode.roundManager.shellSpawner.sequenceArray[0] = "live"
		ApClient.trapQueue.erase(ApClient.I_BULLET_TRAP)
	
	# Shotsanity + Streaksanity
	if (
		mainNode.shellSpawner.sequenceArray[0] == "live"     and who == "dealer"
		or mainNode.shellSpawner.sequenceArray[0] == "blank" and who == "self"
	):
		ApClient.shotsanityCount += 1
		if ApClient.shotsanityCount <= 1000:
			ApClient.SendLocation(
				ApClient.L_OFST_SS + ApClient.shotsanityCount - 1
			)
		
		if who == "dealer":
			ApClient.streak += 1
			print(ApClient.streak)
			if ApClient.streak >= 2 and ApClient.streak <= 10:
				ApClient.SendLocation(
					ApClient.L_OFST_STS + ApClient.streak - 2
				)
	elif mainNode.shellSpawner.sequenceArray[0] == "live" and who == "self":
		ApClient.streak = 0
	
	# Handsaw Buff
	if (
		mainNode.roundManager.barrelSawedOff
		and ApClient.mechanicItems[ApClient.I_OFST_ITEM_BUFF] > 0
	):
		mainNode.roundManager.currentShotgunDamage = 3
	
	chain.execute_next_async([who])


func MainSlowdownRoutine(chain: ModLoaderHookChain, whoCopy : String, fromDealer : bool):
	var mainNode := chain.reference_object as ShotgunShooting
	var ApClient = mainNode.get_tree().root.get_node(APCLIENT_PATH)
	
	chain.execute_next()
	
	if (!fromDealer):
		var healthAfterShot = mainNode.roundManager.health_opponent - mainNode.roundManager.currentShotgunDamage		
		if (
			mainNode.roundManager.barrelSawedOff
			and 2 in ApClient.included_item_debuffs
			and ApClient.mechanicItems[ApClient.I_OFST_ITEM_DEBUFF] == 0
			and healthAfterShot > 0
			and mainNode.shellSpawner.sequenceArray[0] == "live"
			and whoCopy == "dealer"
			and randf() <= 1.0
		):
			mainNode.roundManager.waitingForHealthCheck2 = true
			if (mainNode.shellSpawner.sequenceArray.size() == 1): 
				mainNode.whatTheFuck = true
			mainNode.roundManager.waitingForDealerReturn = true
			mainNode.healthCounter.playerShotSelf = true
			mainNode.playerDied = true
			mainNode.roundManager.health_player -= 1
			if (mainNode.roundManager.health_player < 0): mainNode.roundManager.health_player = 0
			mainNode.playerCanGoAgain = false
			mainNode.healthCounter.checkingPlayer = true
			await(mainNode.death.Kill("player", false, true))
