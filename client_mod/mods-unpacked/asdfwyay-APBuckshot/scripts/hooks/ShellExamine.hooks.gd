extends Node

const APCLIENT_PATH = "/root/ModLoader/asdfwyay-APBuckshot/ApClient"

func SetupShell(chain: ModLoaderHookChain):
	var mainNode := chain.reference_object as ShellExamine
	var ApClient = mainNode.get_tree().root.get_node(APCLIENT_PATH)
	
	chain.execute_next()
	
	if ApClient.checkItemDebuff(3) and randf() <= 0.4:
		mainNode.mesh.set_surface_override_material(1, mainNode.mat)
