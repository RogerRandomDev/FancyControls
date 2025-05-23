@tool
extends PanelContainer


func _ready() -> void:
	$VBoxContainer/NewNodeSearch.text_changed.connect(func(new_text):
		$VBoxContainer/NewNodeList.clear()
		new_text = new_text.to_lower()
		%BlockList.blocks.map(func(v):
			if new_text != "" and not v.BlockName.to_lower().contains(new_text):return
			$VBoxContainer/NewNodeList.add_item(v.BlockName)
		)
		)
	$VBoxContainer/NewNodeSearch.text_changed.emit("")
	$VBoxContainer/NewNodeList.item_activated.connect(func(index):
		visible=false
		var item_text = $VBoxContainer/NewNodeList.get_item_text(index)
		var block_made = %BlockList.create_item_block(item_text,false)
		block_made.position_offset=global_position+$"../Box/MainBox/BlockUI".scroll_offset-$"../Box/MainBox/BlockUI".global_position
		)
	$"../Box/MainBox/BlockUI".gui_input.connect(input_on_grid)

func _input(event: InputEvent) -> void:
	var menu_rect=get_rect()
	menu_rect.position=global_position
	if (
		event is InputEventKey and event.key_label == KEY_ESCAPE or
		event is InputEventMouseButton and not menu_rect.has_point(event.global_position) and event.is_pressed()
		):
		visible=false
		return

func input_on_grid(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.is_pressed():
		if visible:
			visible=false
			return
		visible=true
		global_position=event.global_position
		$VBoxContainer/NewNodeSearch.clear()
		$VBoxContainer/NewNodeSearch.edit()
