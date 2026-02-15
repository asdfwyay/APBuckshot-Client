extends Node

const ASDFWYAY_APBUCKSHOT_DIR := "asdfwyay-APBuckshot"
const ASDFWYAY_APBUCKSHOT_LOG_NAME := "asdfwyay-APBuckshot:Main"

var mod_dir_path := ""
var extensions_dir_path := ""
var hooks_dir_path := ""
var translations_dir_path := ""

func _init() -> void:
	mod_dir_path = ModLoaderMod.get_unpacked_dir().path_join(ASDFWYAY_APBUCKSHOT_DIR)

	var ApClient = load("res://mods-unpacked/asdfwyay-APBuckshot/scripts/APClient.gd").new()
	ApClient.name = "ApClient"
	add_child(ApClient)

	# Add extensions
	install_script_extensions()
	# Add hooks
	install_script_hook_files()
	# Add translations
	add_translations()

func install_script_extensions() -> void:
	extensions_dir_path = mod_dir_path.path_join("extensions")
	# ModLoaderMod.install_script_extension(extensions_dir_path.path_join(...))
	
func install_script_hook_files() -> void:
	hooks_dir_path = mod_dir_path.path_join("hooks")
	
	ModLoaderMod.install_script_hooks(
		"res://scripts/ShotgunShooting.gd",
		"res://mods-unpacked/asdfwyay-APBuckshot/scripts/hooks/ShotgunShooting.hooks.gd"
	)
	ModLoaderMod.install_script_hooks(
		"res://scripts/RoundManager.gd",
		"res://mods-unpacked/asdfwyay-APBuckshot/scripts/hooks/RoundManager.hooks.gd"
	)
	ModLoaderMod.install_script_hooks(
		"res://scripts/MenuManager.gd",
		"res://mods-unpacked/asdfwyay-APBuckshot/scripts/hooks/MenuManager.hooks.gd"
	)
	ModLoaderMod.install_script_hooks(
		"res://scripts/ItemManager.gd",
		"res://mods-unpacked/asdfwyay-APBuckshot/scripts/hooks/ItemManager.hooks.gd"
	)
	ModLoaderMod.install_script_hooks(
		"res://scripts/AchievementManager.gd",
		"res://mods-unpacked/asdfwyay-APBuckshot/scripts/hooks/AchievementManager.hooks.gd"
	)
	ModLoaderMod.install_script_hooks(
		"res://scripts/DonUnlockManager.gd",
		"res://mods-unpacked/asdfwyay-APBuckshot/scripts/hooks/DonUnlockManager.hooks.gd"
	)
	ModLoaderMod.install_script_hooks(
		"res://scripts/UserExit.gd",
		"res://mods-unpacked/asdfwyay-APBuckshot/scripts/hooks/UserExit.hooks.gd"
	)
	ModLoaderMod.install_script_hooks(
		"res://scripts/DeathManager.gd",
		"res://mods-unpacked/asdfwyay-APBuckshot/scripts/hooks/DeathManager.hooks.gd"
	)
	ModLoaderMod.install_script_hooks(
		"res://scripts/EndingManager.gd",
		"res://mods-unpacked/asdfwyay-APBuckshot/scripts/hooks/EndingManager.hooks.gd"
	)

func add_translations() -> void:
	translations_dir_path = mod_dir_path.path_join("translations")
	# ModLoaderMod.add_translation(translations_dir_path.path_join(...))

func _ready() -> void:
	ModLoaderLog.info("Ready!", ASDFWYAY_APBUCKSHOT_LOG_NAME)
	
	if FileAccess.file_exists("user://buckshotroulette_pills.shell.bkp"):
		DirAccess.copy_absolute(
			"user://buckshotroulette_pills.shell.bkp",
			"user://buckshotroulette_pills.shell"
		)
		DirAccess.remove_absolute("user://buckshotroulette_pills.shell.bkp")
	
	for child in get_tree().root.get_children():
		print(child.name)
		
	get_tree().set_auto_accept_quit(false)
