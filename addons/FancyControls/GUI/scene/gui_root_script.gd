@tool
extends Control

@onready var json_converted=load("res://addons/FancyControls/GUI/converters/json_visual_converter.gd").new()
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
func _input(event):
	if visible and event is InputEventKey and event.is_pressed() and event.ctrl_pressed and String(self.get_path_to(get_tree().root.gui_get_focus_owner())).begins_with("."):
		accept_event()

func _on_tab_bar_tab_selected(tab):
	$Box/MainBox.visible=tab==0
	$Box/CodeBox.visible=tab==1
	if tab==1:
		$Box/CodeBox.reload_codeview()


func _on_save_button_pressed():
	if $Box/TopBar/Label.text=="":
		$Box/TopBar/Label.grab_focus()
		return
	if FileAccess.file_exists("res://AnimationChains/example_animation_chains/%s.json"%$Box/TopBar/Label.text):
		$ConfirmationDialog.visible=true
		
		return
	_save_confirmed()
func _save_confirmed():
	var converted_json=json_converted.convert_tree($Box/MainBox/BlockUI)
	var file=FileAccess.open("res://AnimationChains/example_animation_chains/%s.json"%$Box/TopBar/Label.text,FileAccess.WRITE)
	file.store_string(JSON.stringify(converted_json))
	file.close()


func _on_load_button_pressed():
	if $Box/TopBar/Label.text=="":return
	if not FileAccess.file_exists("res://AnimationChains/example_animation_chains/%s.json"%$Box/TopBar/Label.text):return
	for child in $Box/MainBox/BlockUI.get_children():
		if child.name=="StartNode":continue
		if child.name=="StartContainerNode":continue
		$Box/MainBox/BlockUI.remove_child(child)
		child.queue_free()
	$Box/MainBox/BlockUI.clear_connections()
	await get_tree().process_frame
	var file=FileAccess.open("res://AnimationChains/example_animation_chains/%s.json"%$Box/TopBar/Label.text,FileAccess.READ)
	json_converted.convert_json(
		JSON.parse_string(file.get_as_text()),
		$Box/MainBox/BlockUI,
		$Box/MainBox/VBoxContainer/BlockList
	)
	file.close()

