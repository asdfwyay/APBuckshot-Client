extends Node

func EndMainBatch(chain: ModLoaderHookChain):
	var mainNode := chain.reference_object as RoundManager
	var ApClient = mainNode.get_tree().root.get_node("/root/ModLoader/asdfwyay-APBuckshot/ApClient")
	
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
	var ApClient = mainNode.get_tree().root.get_node("/root/ModLoader/asdfwyay-APBuckshot/ApClient")
	
	chain.execute_next_async()
	
	if ApClient.awaitingDeathLink:
		mainNode.health_player = 1
		mainNode.shellSpawner.sequenceArray[0] = "live"
		mainNode.camera.BeginLerp("enemy")
		mainNode.dealerAI.GrabShotgun()
		mainNode.itemManager.dialogue.ShowText_ForDuration(
			"YOU'VE BEEN DEATHLINKED",
			3.0
		)
		mainNode.dealerAI.Shoot("player")
	ApClient.isPlayerTurn = true
