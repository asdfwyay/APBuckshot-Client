extends Node

var old_array_amounts = {}

func GrabItem(chain: ModLoaderHookChain):
	var mainNode := chain.reference_object as ItemManager
	var ApClient = mainNode.get_tree().root.get_node("/root/ModLoader/asdfwyay-APBuckshot/ApClient")
	
	var roundManager = mainNode.roundManager
	
	var active_items = 0
	var zero_active_count = 0
	for i in range(9):
		if mainNode.amounts.array_amounts[i].amount_active == 0:
			zero_active_count += 1
		else:
			active_items += mainNode.amounts.array_amounts[i].amount_active
	
	if ApClient.obtainedItems.is_empty() or active_items == 0 or (
		mainNode.numberOfItemsGrabbed == roundManager.roundArray[roundManager.currentRound].numberOfItemsToGrab
		) or (
		roundManager.currentRound == 0
		and roundManager.roundArray[roundManager.currentRound].startingHealth == 2
		and 2.0 in ApClient.obtainedItems
		and ApClient.obtainedItems.size() == 1
	):
		mainNode.EndItemGrabbing()
		return
		
	var pull_item: int = randi_range(2,10 - zero_active_count)
	if float(pull_item) not in ApClient.obtainedItems:
		mainNode.numberOfItemsGrabbed += 1
		
		var sound = load("res://audio/item grid indicator blip.ogg")
		mainNode.speaker_itemgrab.stream = sound
		mainNode.speaker_itemgrab.play()
		
		return
	
	for id in range(2,11):
		if float(id) not in ApClient.obtainedItems:
			old_array_amounts[id-2] = mainNode.amounts.array_amounts[id-2].amount_active
			mainNode.amounts.array_amounts[id-2].amount_active = 0
			
	print(old_array_amounts)
	
	chain.execute_next_async()
	
	for id in old_array_amounts:
		mainNode.amounts.array_amounts[id].amount_active = old_array_amounts[id]
