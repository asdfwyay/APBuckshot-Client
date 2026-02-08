extends Node

@export var item_resource_path: String

@onready var sub_viewport = $"IndicatorVPContainer/IndicatorVP"

var item_instance: MeshInstance3D
var shell_branch

var is_live: bool = false
var time_since_last_flip: float = 0.0

func _ready():
	item_instance = load(item_resource_path).instantiate()
	sub_viewport.add_child(item_instance)
	shell_branch = item_instance.get_node("shell branch")

func _process(delta):
	time_since_last_flip += delta
	if (time_since_last_flip >= 0.25):
		if (is_live):
			item_instance.set_surface_override_material(1, shell_branch.mat_blank)
		else:
			item_instance.set_surface_override_material(1, shell_branch.mat_live)
		is_live = !is_live
		time_since_last_flip = 0.0
