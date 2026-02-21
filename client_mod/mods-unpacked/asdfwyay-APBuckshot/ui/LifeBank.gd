extends Control

var ApClient
var icon_model

@onready var icon: TextureRect = $"LifeBankContainer/Icon"
@onready var charge_container: Panel = $"LifeBankContainer/Icon/ChargeCountCanvas/ChargeCountContainer"
@onready var charge_label: Label = $"LifeBankContainer/Icon/ChargeCountCanvas/ChargeCountContainer/charge_count"
@onready var sub_viewport: SubViewport = $"IconTextureContainer/SubViewport"


func _ready():
	ApClient = $"/root/ModLoader/asdfwyay-APBuckshot/ApClient"
	
	var model_doc = GLTFDocument.new()
	var model_state = GLTFState.new()
	var err = model_doc.append_from_file(
		"res://mods-unpacked/asdfwyay-APBuckshot/models/life_bank_icon.glb",
		model_state
	)
	if err == OK:
		icon_model = model_doc.generate_scene(model_state)
	
	sub_viewport.add_child(icon_model)
	
	icon_model.position = Vector3.ZERO
	icon_model.rotation = Vector3.ZERO
	icon_model.scale = Vector3.ONE
	
	charge_container.size.x = 40
	charge_container.visible = false
	
	charge_label.size.x = 40


func _process(delta):
	charge_container.visible = charge_container.size.x > 50
	
	if (ApClient.mechanicItems.has(ApClient.I_LIFE_BANK)):
		charge_label.text = "%d/%d" % [
			ApClient.lifeBankCharges,
			ApClient.mechanicItems[ApClient.I_LIFE_BANK]
		]
		
		if ApClient.lifeBankCharges == 0:
			charge_label.set("theme_override_colors/font_color", Color8(204, 51, 0))
		elif ApClient.lifeBankCharges == ApClient.mechanicItems[ApClient.I_LIFE_BANK]:
			charge_label.set("theme_override_colors/font_color", Color8(0, 255, 0))
		else:
			charge_label.set("theme_override_colors/font_color", Color8(255, 255, 255))


func _on_icon_mouse_entered():
	var hover_in_tween: Tween = create_tween()
	hover_in_tween.set_ease(Tween.EASE_OUT)
	hover_in_tween.set_trans(Tween.TRANS_CUBIC)
	hover_in_tween.tween_property(icon_model, "position", Vector3(0, 0, 0), 1.0)
	hover_in_tween.set_parallel()
	hover_in_tween.tween_property(icon_model, "rotation:z", 4*PI, 1.0)
	hover_in_tween.tween_property(icon_model, "scale", Vector3(1.4, 1.4, 1.4), 1.0)
	hover_in_tween.tween_property(charge_container, "size:x", 120, 1.0)
	hover_in_tween.tween_property(charge_label, "size:x", 95, 1.0)
	
	hover_in_tween.play()


func _on_icon_mouse_exited():
	var hover_out_tween: Tween = create_tween()
	hover_out_tween.set_ease(Tween.EASE_OUT)
	hover_out_tween.set_trans(Tween.TRANS_CUBIC)
	hover_out_tween.tween_property(icon_model, "position", Vector3(0, 0, 0), 1.0)
	hover_out_tween.set_parallel()
	hover_out_tween.tween_property(icon_model, "rotation:z", 0, 1.0)
	hover_out_tween.tween_property(icon_model, "scale", Vector3(1, 1, 1), 1.0)
	hover_out_tween.tween_property(charge_container, "size:x", 40, 1.0)
	hover_out_tween.tween_property(charge_label, "size:x", 40, 1.0)
	
	hover_out_tween.play()


func _on_icon_gui_input(event):
	if (
		event is InputEventMouseButton
		and event.button_index == MOUSE_BUTTON_LEFT
		and event.pressed
	):
		var health_counter: HealthCounter = get_tree().root.get_node(
			"/root/main/standalone managers/health counter"
		)
		var round_manager: RoundManager = get_tree().root.get_node(
			"/root/main/standalone managers/round manager"
		)
		
		if !health_counter or !round_manager:
			return
		
		var curHealth = round_manager.health_player
		var maxHealth
		if (round_manager.roundArray.is_empty()):
			maxHealth = 0
		else:
			maxHealth = round_manager.roundArray[0].startingHealth
		
		print(ApClient.isPlayerTurn)
		if (ApClient.isPlayerTurn and ApClient.lifeBankCharges > 0):
			if (curHealth < maxHealth and !round_manager.wireIsCut_player):
				ApClient.lifeBankCharges -= 1
			health_counter.overriding_medicine = false
			health_counter.UpdateDisplayRoutineCigarette_Player()
