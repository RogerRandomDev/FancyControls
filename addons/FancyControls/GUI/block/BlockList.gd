@tool
extends Tree



##gonna use a custom _get_property_list() method to work on this and make it easier to work with
@export var BlockList:CodeBlockListResource

var blocks:Array[CodeBlockResource]:
	get:return BlockList.block_list

var categories:Dictionary={}

var root_item:TreeItem

func _ready():
	clear()
	root_item=create_item()
	
	load_blocks_into_list()

func load_blocks_into_list()->void:
	for block in blocks:
		ensure_categories_loaded(block)
		add_block_to_categories(block)


func ensure_categories_loaded(block)->void:
	for category in block.BlockCategories:
		if categories.has(category):continue
		var category_item = root_item.create_child()
		category_item.set_text(0,category)
		categories[category]=category_item

func add_block_to_categories(block)->void:
	for category in block.BlockCategories:
		var block_item = categories[category].create_child()
		block_item.set_text(0,block.BlockName)
		block_item.set_meta("SourceRef",block)


func search_items(search_string:String="",search_category:String="")->void:
	
	search_string=search_string.to_lower()
	search_category=search_category.to_lower()
	var used_list:=blocks.filter(func(block):
		return (search_category=="any"||block.BlockCategories.has(search_category.to_lower())) and (block.BlockName.to_lower().contains(search_string)||search_string=="")
	)


func _on_item_selected():
	##code that allows me to collapse all but the current relevant category group
	#var chosen_item=get_selected()
	#while chosen_item.get_parent()!=root_item:
		#chosen_item=chosen_item.get_parent()
	#
	#for item in root_item.get_children():
		#item.collapsed=item!=get_selected()
	
	
	if get_selected().get_parent()==root_item:return
	
	var name_of_block=get_selected().get_text(0)
	if not blocks.any(func(v):return v.BlockName==name_of_block):return
	create_item_block(name_of_block)


func create_item_block(name_of_block,select:bool=true,attach_to:Node=null):
	
	var added_block=blocks.filter(func(v):return v.BlockName==name_of_block)[0].build_block()
	
	#compiles info as needed to re-link cause it hates me
	for child in added_block.get_children():
		for options in child.get_children():
			if options.has_meta(&"link"):
				var link_info=options.get_meta(&"link")
				options.connect(link_info[0],link_info[2].bind(added_block))
				item_block_func.call_deferred(options,link_info,added_block,child)
				options.remove_meta(&"link")
	added_block.disconnected_port.connect(func(id,node):
		id-=int(node.get_parent().get_meta(&"runnable",false))
		if added_block.has_meta(&"default_%s"%str(id)):
			added_block.set_meta(&"value_%s"%str(id),added_block.get_meta(&"default_%s"%str(id)))
		if added_block.has_meta(&"reset_type_%s"%str(id)):
			added_block.set_meta(&"type_%s"%str(id),added_block.get_meta(&"reset_type_%s"%str(id)))
	)
	if attach_to==null:attach_to=$"../../BlockUI"
	attach_to.attach_node(added_block)
	if !select:return added_block
	await get_tree().process_frame
	if attach_to==$"../../BlockUI":
		$"../../BlockUI".set_selected(added_block)
		$"../../BlockUI".grab_focus()
		added_block.position_offset=($"../../BlockUI".scroll_offset+$"../../BlockUI".size*0.5-added_block.size*0.5-size*Vector2(0.5,0))/$"../../BlockUI".zoom
	return added_block


func item_block_func(options,link_info,added_block,child):
	await get_tree().process_frame
	var ind=added_block.get_children().find(child)-int(added_block.get_meta(&"runnable"))
	if options.has_meta(&"reset_value"):
		added_block.connect("disconnected_port",func(v,b):
			if b==options.get_parent():
				added_block.set_meta(&"value_%s"%str(ind),options.get_meta(&"reset_value"))
			)
	
	if added_block.has_meta(&"value_%s"%str(ind)):
		var val=added_block.get_meta(&"value_%s"%str(ind))
		if options is SpinBox and val is Vector2:
			
			options.value=val[int(options.get_parent().get_children().find(options))-1]
		if options is OptionButton:
			for item in options.item_count:
				if val.ends_with(options.get_item_text(item)):
					options.select(item);break
		
		if options is SpinBox and val is float:
			options.value=val
		if options is LineEdit and val is String:
			options.text=val
		return options.emit_signal(link_info[0],val)
	options.emit_signal(link_info[0],link_info[1])





func _on_option_button_item_selected(index):
	var a=OptionButton.new()
	
	search_items($"../HBoxContainer/LineEdit".text,$"../HBoxContainer/OptionButton".get_item_text($"../HBoxContainer/OptionButton".get_selected_id()))


func _on_line_edit_text_changed(new_text):
	search_items($"../HBoxContainer/LineEdit".text,$"../HBoxContainer/OptionButton".get_item_text($"../HBoxContainer/OptionButton".get_selected_id()))

#used to manage double  clicking to expand and shrink the block type list
func _on_item_activated():
	if get_selected().get_parent()!=root_item:return
	get_selected().collapsed=!get_selected().collapsed
	
