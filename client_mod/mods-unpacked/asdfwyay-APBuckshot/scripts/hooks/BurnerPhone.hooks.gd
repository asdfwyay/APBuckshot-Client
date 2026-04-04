extends Node

const APCLIENT_PATH = "/root/ModLoader/asdfwyay-APBuckshot/ApClient"


func SendDialogue(chain: ModLoaderHookChain) -> void:
	var mainNode := chain.reference_object as BurnerPhone
	var ApClient = mainNode.get_tree().root.get_node(APCLIENT_PATH)
	var shellIndex = GlobalVariables.get_meta("burner_phone_choice")
	
	print("Starting SendDialogue")
	
	if shellIndex > 0:
		var firstpart = tr("SEQUENCE%d" % shellIndex)
		var secondpart = ""
		var fulldia = ""
		
		if (mainNode.sh.sequenceArray[shellIndex - 1] == "blank"):
			secondpart = tr("BLANKROUND") % ""
		else:
			secondpart = tr("LIVEROUND") % ""
		
		if (
			mainNode.sh.sequenceArray.size() <= 1
			or (
				8 in ApClient.included_item_debuffs
				and ApClient.mechanicItems[ApClient.I_OFST_ITEM_DEBUFF + 6] == 0
				and randf() <= 0.25
			)
		):
			fulldia = tr("UNFORTUNATE")
		else:
			fulldia = tr(firstpart) + "\n" + "... " + tr(secondpart)
			
		GlobalVariables.set_meta("burner_phone_choice", 0)
		
		mainNode.dia.ShowText_Forever(fulldia)
		await mainNode.get_tree().create_timer(3, false).timeout
		mainNode.dia.HideText()
	else:
		await chain.execute_next_async()
