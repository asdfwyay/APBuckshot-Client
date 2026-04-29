extends Tree

var ApClient
var rows: Dictionary = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	ApClient = $"/root/ModLoader/asdfwyay-APBuckshot/ApClient"
	columns = 2
	
	var root = create_item()
	hide_root = true
	
	set_column_title(0, "Stat")
	set_column_title(1, "Value")
	set_column_expand_ratio(0, 3)
	
	rows["pts"] = create_item(root)
	rows["pts"].set_text(0, "Points Obtained")
	
	rows["shotsanity"] = create_item(root)
	rows["shotsanity"].set_text(0, "Current Shotsanity")
	
	rows["streaksanity"] = create_item(root)
	rows["streaksanity"].set_text(0, "Highest Streak")
	
	if ApClient.mechanicItems.has(ApClient.I_LIFE_BANK):
		rows["life_bank"] = create_item(root)
		rows["life_bank"].set_text(0, "Life Bank Charges")
	
	rows["item_luck_base"] = create_item(root)
	rows["item_luck_base"].set_text(0, "Item Draw Chance (Base)")
	
	rows["item_luck_don"] = create_item(root)
	rows["item_luck_don"].set_text(0, "Item Draw Chance (DoN)")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func update_all():
	update_pts()
	update_shotsanity()
	update_streaksanity()
	update_item_luck()
	if ApClient.mechanicItems.has(ApClient.I_LIFE_BANK):
		update_life_bank()


func update_pts():
	var val
	if ApClient.goalAmt > 0:
		val = "%d/%d" % [ApClient.async_point_total, ApClient.goalAmt]
	else:
		val = str(ApClient.async_point_total)
	rows["pts"].set_text(1, val)


func update_shotsanity():
	var val
	if ApClient.shotsanity_goal_count > 0:
		val = "%d/%d/%d" % [ApClient.shotsanityCount, ApClient.shotsanity_goal_count, ApClient.total_shotsanity_count]
	else:
		val = "%d/%d" % [ApClient.shotsanityCount, ApClient.total_shotsanity_count]
	rows["shotsanity"].set_text(1, val)


func update_streaksanity():
	var val
	if ApClient.streaksanity_count > 0:
		val = "%d/%d" % [ApClient.max_streak, ApClient.streaksanity_count]
	else:
		val = str(ApClient.max_streak)
	rows["streaksanity"].set_text(1, val)


func update_item_luck():
	var num_items_base = ApClient.obtainedItems.filter(
		func(x): return x >= 2 and x <= 6
	).size()
	var num_items_don = ApClient.obtainedItems.filter(
		func(x): return x >= 2 and x <= 10
	).size()
	
	var trials = 1
	if ApClient.mechanicItems.has(ApClient.I_ITEM_LUCK):
		trials += ApClient.mechanicItems[ApClient.I_ITEM_LUCK]
	
	var chance_base = int(100.0 * (1.0 - (1.0 - float(num_items_base) / 5.0) ** trials))
	var chance_don = int(100.0 * (1.0 - (1.0 - float(num_items_don) / 9.0) ** trials))
	
	rows["item_luck_base"].set_text(1, "%d%%" % [chance_base])
	rows["item_luck_don"].set_text(1, "%d%%" % [chance_don])


func update_life_bank():
	rows["life_bank"].set_text(1, str(ApClient.mechanicItems[ApClient.I_LIFE_BANK]))
