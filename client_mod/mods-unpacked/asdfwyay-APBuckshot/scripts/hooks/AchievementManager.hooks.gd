extends Node

const APCLIENT_PATH = "/root/ModLoader/asdfwyay-APBuckshot/ApClient"


func UnlockAchievement(chain: ModLoaderHookChain, apiname: String) -> void:
	var mainNode := chain.reference_object as Achievement
	var ApClient = mainNode.get_tree().root.get_node(APCLIENT_PATH)

	match apiname:
		"ach1": # 70K
			ApClient.SendLocation(0x0100 + 1)
		"ach2": # Bronze Gates
			ApClient.SendLocation(0x0100 + 3)
		"ach3": # Chasing Losses
			ApClient.SendLocation(0x0100 + 8)
			ApClient.SendLocation(0x0100 + 12)
		"ach4": # Overdose
			ApClient.SendLocation(0x0100 + 12)
		"ach5": # Nope
			ApClient.SendLocation(0x0100 + 10)
		"ach6": # 140K
			ApClient.SendLocation(0x0100 + 11)
		"ach7": # 1000K
			ApClient.SendLocation(0x0100 + 14)
		"ach8": # Coin Flip
			ApClient.SendLocation(0x0100 + 2)
		"ach9": # Digita, Orava and Koni
			ApClient.SendLocation(0x0100 + 13)
		"ach10": # Know When To Quit
			ApClient.SendLocation(0x0100 + 15)
		"ach11": # Name Taken
			ApClient.SendLocation(0x0100 + 4)
		"ach12": # Full House
			ApClient.SendLocation(0x0100 + 16)
		"ach13": # Why?
			ApClient.SendLocation(0x0100 + 6)
		"ach14": # Soak It In
			ApClient.SendLocation(0x0100 + 5)
		"ach15": # Going Out With Style!
			ApClient.SendLocation(0x0100 + 7)
		"ach16": # High Rollers
			ApClient.SendLocation(0x0100 + 9)
	
	chain.execute_next([apiname])
