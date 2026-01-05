extends Node

func ExitGame(chain: ModLoaderHookChain):
	var mainNode := chain.reference_object as ExitManager
	if mainNode.get_tree().get_root().has_node("APOverlay"):
		mainNode.get_tree().get_root().get_node("APOverlay").queue_free()
	chain.execute_next()
