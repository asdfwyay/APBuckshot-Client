extends Node

signal show_tracker_info(id: int, name: String, vp: Viewport)
signal hide_tracker_info()

@export var id: int
@export var item_name: String
@export var item_resource_path: String
@export var vert_offset: float = 0

@onready var sub_viewport = $"ItemContainer/SubViewport"
var item_instance: MeshInstance3D

func _ready():
	item_instance = load(item_resource_path).instantiate()
	sub_viewport.add_child(item_instance)
	
	item_instance.position.y = vert_offset
	update_transparency(float(id), 0.8)

func _process(delta):
	random_rotate(delta)

func random_rotate(delta):
	var speed = 1.0
	item_instance.position.y = 0
	
	item_instance.rotate_x(speed*delta*randf_range(0, 1))
	item_instance.rotate_y(speed*delta*randf_range(0, 1))
	item_instance.rotate_z(speed*delta*randf_range(0, 1))
	
	item_instance.position.y = vert_offset

func _on_mouse_entered():
	show_tracker_info.emit(id, item_name, sub_viewport)

func _on_mouse_exited():
	hide_tracker_info.emit()

func update_transparency(set_id, a):
	if float(id) != set_id:
		return
		
	item_instance.transparency = a
	for child in item_instance.get_children():
		if child is MeshInstance3D:
			child.transparency = a
