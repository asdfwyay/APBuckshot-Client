extends Node

func UnlockAchievement(chain: ModLoaderHookChain, apiname: String) -> void:
	var mainNode := chain.reference_object as Achievement
	var ApClient = mainNode.get_tree().root.get_node("/root/ModLoader/asdfwyay-APBuckshot/ApClient")

	match apiname:
		"ach1":
			ApClient.SendLocation(6)
		"ach2":
			ApClient.SendLocation(8)
		"ach3":
			ApClient.SendLocation(13)
		"ach4":
			ApClient.SendLocation(17)
		"ach5":
			ApClient.SendLocation(15)
		"ach6":
			ApClient.SendLocation(16)
		"ach7":
			ApClient.SendLocation(19)
		"ach8":
			ApClient.SendLocation(7)
		"ach9":
			ApClient.SendLocation(18)
		"ach10":
			ApClient.SendLocation(20)
		"ach11":
			ApClient.SendLocation(9)
		"ach12":
			ApClient.SendLocation(21)
		"ach13":
			ApClient.SendLocation(11)
		"ach14":
			ApClient.SendLocation(10)
		"ach15":
			ApClient.SendLocation(12)
		"ach16":
			ApClient.SendLocation(14)
	
	chain.execute_next([apiname])
