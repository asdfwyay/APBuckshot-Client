extends Node

const APCLIENT_PATH = "/root/ModLoader/asdfwyay-APBuckshot/ApClient"


func MainBatchSetup(chain: ModLoaderHookChain, dealerEnterAtStart : bool):
	var mainNode := chain.reference_object as RoundManager
	var ApClient = mainNode.get_tree().root.get_node(APCLIENT_PATH)
	
	ApClient.item_buff_states["beer"] = true
	
	chain.execute_next_async([dealerEnterAtStart])


func EndMainBatch(chain: ModLoaderHookChain):
	var mainNode := chain.reference_object as RoundManager
	var ApClient = mainNode.get_tree().root.get_node(APCLIENT_PATH)
	
	var endless = mainNode.endless
	var playerData = mainNode.playerData
	var currentRound = mainNode.currentRound
	var double_or_nothing_rounds_beat = mainNode.double_or_nothing_rounds_beat
	
	print("Current round: %d, %d" % [currentRound, playerData.currentBatchIndex])
	
	if (!endless):
		match playerData.currentBatchIndex:
			0:
				ApClient.SendLocation(1)
				ApClient.SendLocation(2)
			1:
				ApClient.SendLocation(3)
				ApClient.SendLocation(4)
			2:
				ApClient.SendLocation(5)
	else:
		var locationOffset = 3*double_or_nothing_rounds_beat + playerData.currentBatchIndex
		if locationOffset >= 0 and locationOffset <= 35:
			ApClient.SendLocation(0x0200 + 1 + 2*locationOffset)
			ApClient.SendLocation(0x0200 + 2 + 2*locationOffset)
	
	ApClient.poison = 0
	chain.execute_next_async()


func SetupDeskUI(chain: ModLoaderHookChain):
	var mainNode := chain.reference_object as RoundManager
	var ApClient = mainNode.get_tree().root.get_node(APCLIENT_PATH) 
	
	chain.execute_next_async()
	
	if ApClient.awaitingDeathLink:
		var willDie: bool
		if ApClient.lifeBankCharges > 0:
			ApClient.lifeBankCharges -= 1
			ApClient.awaitingDeathLink = false
			
			if (
				mainNode.playerData.currentBatchIndex == 2
				and not mainNode.wireIsCut_player
				and not mainNode.endless
			):
				mainNode.health_player = mainNode.currentShotgunDamage + 3
			else:
				mainNode.health_player = mainNode.currentShotgunDamage + 1
			willDie = false
		else:
			mainNode.health_player = 1
			willDie = true
			
		mainNode.shellSpawner.sequenceArray[0] = "live"
		mainNode.ClearDeskUI(true)
		mainNode.perm.SetIndicators(false)
		mainNode.perm.SetInteractionPermissions(false)
		mainNode.perm.RevertDescriptionUI()
		
		if (
			willDie
			and mainNode.playerData.currentBatchIndex == 2
			and not mainNode.wireIsCut_player
			and not mainNode.endless
		):
			mainNode.wireIsCut_player = true
		
		mainNode.camera.BeginLerp("enemy")
		await mainNode.get_tree().create_timer(0.6, false).timeout
		mainNode.dealerAI.GrabShotgun()
		await mainNode.get_tree().create_timer(0.9, false).timeout
		mainNode.itemManager.dialogue.ShowText_ForDuration(
			ApClient.death_msg,
			3.0,
		)
		await mainNode.get_tree().create_timer(3, false).timeout
		mainNode.dealerAI.Shoot("player")
		
		if not willDie:
			mainNode.perm.SetIndicators(true)
			mainNode.perm.SetInteractionPermissions(true)
			mainNode.SetupDeskUI()
	else:
		var poisonDmg = floor(ApClient.poison / 100)
		var f = float(ApClient.poison) / 100.0 - float(poisonDmg)
		if randf() <= f:
			poisonDmg += 1
		
		print("f: %f | Poison Dmg: %f" % [f, poisonDmg])
		if not ApClient.isPlayerTurn and poisonDmg > 0:
			var prevHealth = mainNode.health_player
			mainNode.health_player -= poisonDmg
			if (
				mainNode.playerData.currentBatchIndex == 2
				and not mainNode.wireIsCut_player
				and not mainNode.endless
				and mainNode.health_player < 3
			):
				mainNode.health_player = 3
			elif mainNode.health_player < 1:
				mainNode.health_player = 1
			
			if prevHealth - mainNode.health_player > 0:
				mainNode.healthCounter.overriding_medicine = true
				mainNode.healthCounter.overriding_medicine_adding = false
				await mainNode.healthCounter.UpdateDisplayRoutineCigarette_Main(true, false)
				mainNode.healthCounter.overriding_medicine = false
	
	ApClient.isPlayerTurn = true
	ApClient.hasUsedHandsaw = false
