extends Node

const APCLIENT_PATH = "/root/ModLoader/asdfwyay-APBuckshot/ApClient"

func PickupItemFromTable(chain: ModLoaderHookChain, itemParent : Node3D, passedItemName : String):
	var mainNode := chain.reference_object as ItemInteraction
	var ApClient = mainNode.get_tree().root.get_node(APCLIENT_PATH)
	var roundManager = mainNode.roundManager
	
	print("Starting PickupItemFromTable")
	
	mainNode.perm.SetIndicators(false)
	mainNode.perm.SetInteractionPermissions(false)
	mainNode.perm.RevertDescriptionUI()
	mainNode.roundManager.ClearDeskUI(true)
	
	match (passedItemName):
		"magnifying glass":
			if ApClient.mechanicItems[ApClient.I_OFST_ITEM_BUFF + 1] > 0:
				ApClient.request_mag_choice.emit()
				var res = await ApClient.send_mag_choice
				if res != "none":
					if randf() <= 0.5:
						ApClient.send_notification.emit(
							"Conversion sucessful (Originally %s)" % roundManager.shellSpawner.sequenceArray[0]
						)
						mainNode.roundManager.shellSpawner.sequenceArray[0] = res
					else:
						ApClient.send_notification.emit("Conversion failed")
		"beer":
			if (
				ApClient.mechanicItems[ApClient.I_OFST_ITEM_BUFF + 2] > 0
				and ApClient.item_buff_states["beer"]
			):
				ApClient.request_beer_choice.emit()
				var res = await ApClient.send_beer_choice
				if res:
					if ApClient.checkItemDebuff(4):
						ApClient.poison += 10 * (mainNode.roundManager.shellSpawner.sequenceArray.size() - 1)
					mainNode.roundManager.shellSpawner.sequenceArray.resize(1)
					ApClient.item_buff_states["beer"] = false
			if ApClient.checkItemDebuff(4):
				ApClient.poison += 15
		"cigarettes":
			if (
				ApClient.mechanicItems[ApClient.I_OFST_ITEM_BUFF + 3] > 0
				and randf() <= 0.5
			):
				var maxHealth = roundManager.roundArray[0].startingHealth
				mainNode.roundManager.health_player += 1
				if mainNode.roundManager.health_player > maxHealth - 1:
					mainNode.roundManager.health_player = maxHealth - 1
			if ApClient.checkItemDebuff(5):
				ApClient.poison += 30
		"handcuffs":
			if ApClient.mechanicItems[ApClient.I_OFST_ITEM_BUFF + 4] > 0:
				ApClient.item_buff_states["handcuffs"] = true
		"burner phone":
			if (
				ApClient.mechanicItems[ApClient.I_OFST_ITEM_BUFF + 6] > 0
				and roundManager.shellSpawner.sequenceArray.size() >= 2
			):
				ApClient.request_phone_choice.emit(roundManager.shellSpawner.sequenceArray.size())
				var res = await ApClient.send_phone_choice
				GlobalVariables.set_meta("burner_phone_choice", res)
		"adrenaline":
			if ApClient.checkItemDebuff(9):
				ApClient.poison += 50
		"inverter":
			if ApClient.mechanicItems[ApClient.I_OFST_ITEM_BUFF + 8] > 0:
				ApClient.dealerTrapQueue.append(ApClient.I_BULLET_TRAP)
	
	await chain.execute_next_async([itemParent, passedItemName])
	
	match (passedItemName):
		"inverter":
			if ApClient.checkItemDebuff(10) and randf() <= 0.25:
				if (mainNode.roundManager.shellSpawner.sequenceArray[0] == "live"):
					mainNode.roundManager.shellSpawner.sequenceArray[0] = "blank"
				else:
					mainNode.roundManager.shellSpawner.sequenceArray[0] = "live"
	print("Finishing PickupItemFromTable")
