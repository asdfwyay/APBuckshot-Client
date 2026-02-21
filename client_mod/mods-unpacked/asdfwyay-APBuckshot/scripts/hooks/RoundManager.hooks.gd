extends Node

const APCLIENT_PATH = "/root/ModLoader/asdfwyay-APBuckshot/ApClient"


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
			ApClient.SendLocation(22 + 2*locationOffset)
			ApClient.SendLocation(23 + 2*locationOffset)
	
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
	
	ApClient.isPlayerTurn = true
