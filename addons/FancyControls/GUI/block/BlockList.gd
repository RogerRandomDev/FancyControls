@tool
extends Tree



##gonna use a custom _get_property_list() method to work on this and make it easier to work with
var block_list:Array=[]
var built_nodes:Dictionary={
	
}

var block_categories={}

var root_item:TreeItem

func _ready():
	clear()
	root_item=create_item()
	
	#loads the blocks into the ui to edit with
	#this will need heavily remade for now i just need it functional though
	for block in block_list:
		build_block_node(block)



func search_items(search_string:String="",search_category:String="")->void:
	
	search_string=search_string.to_lower()
	search_category=search_category.to_lower()
	var used_list:=block_list.filter(func(block):
		return (search_category=="any"||block.category.to_lower().split(",").has(search_category)) and (block.name.to_lower().contains(search_string)||search_string=="")
	)
	#for block in used_list:
		#add_item(block.name)







func build_block_node(block):
	
	for category in block.category.split(","):
		if not block_categories.has(category):
			block_categories[category]=root_item.create_child()
			block_categories[category].set_text(0,category)
			block_categories[category].collapsed=true
		var child=block_categories[category].create_child()
		child.set_text(0,block.name)
		(child as TreeItem).set_tooltip_text(0,block.description)
		
	
	var built_block=GraphNode.new()
	built_block.set_script(load("res://addons/FancyControls/GUI/block/block_script.gd"))
	built_block.size.x=160
	built_block.title=block.name
	var i=0
	#adds the RUN block onto the block so it can be executed
	if block.runnable:
		var run_item=Label.new()
		run_item.text="RUN"
		built_block.add_child(run_item)
		run_item.owner=built_block
		built_block.set_slot_enabled_left(i,true)
		built_block.set_slot_enabled_right(0,true)
		built_block.set_slot_color_left(i,Color("ff7664"))
		built_block.set_slot_color_right(i,Color("ff7664"))
		i+=1
	built_block.name=block.name
	
	built_block.set_meta(&"action",block.name)
	built_block.set_meta(&"type",block.type)
	built_block.set_meta(&"runnable",block.runnable)
	var val=0
	for block_property in block.properties:
		built_block.set_meta(&"default_%s"%str(val),block_property.default)
		var added_item=HBoxContainer.new()
		
		var lbl=Label.new()
		if block_property.name=="Out":lbl.horizontal_alignment=HORIZONTAL_ALIGNMENT_RIGHT
		lbl.text=block_property.name
		added_item.add_child(lbl)
		built_block.add_child(added_item)
		added_item.owner=built_block
		lbl.owner=built_block
		
		
		built_block.set_slot_enabled_left(i,block_property.connect_left)
		built_block.set_slot_enabled_right(i,block_property.connect_right)
		built_block.set_meta(&"value_%s"%str(val),block_property.default)
		built_block.set_meta(&"type_%s"%str(val),block_property.type)
		built_block.set_meta(&"reset_type_%s"%str(val),block_property.type)
		match block_property.type:
			TYPE_INT:
				pass
			TYPE_FLOAT:
				if block_property.editable:
					var edit=SpinBox.new()
					edit.allow_greater=true
					edit.allow_lesser=true
					edit.step=0.01
					added_item.add_child(edit)
					edit.set_meta(&"reset_value",block_property.default)
					edit.set_meta(&"link",['value_changed',block_property.default,func(v,link_block):
						if not edit.visible:return
						if v is float:edit.value=v
						link_block.set_meta(&"value_%s"%str(val),v)])
					edit.size_flags_horizontal=Control.SIZE_EXPAND_FILL
					edit.owner=built_block
				BlockColoring.ChangePortType(built_block,i,
				int(block_property.connect_left)+int(block_property.connect_right)*2,
				TYPE_FLOAT
				)
			TYPE_VECTOR2:
				BlockColoring.ChangePortType(built_block,i,
				int(block_property.connect_left)+int(block_property.connect_right)*2,
				TYPE_VECTOR2
				)
				if block_property.editable:
					var edit=SpinBox.new()
					edit.allow_greater=true
					edit.allow_lesser=true
					edit.step=0.01
					added_item.add_child(edit)
					edit.set_meta(&"reset_value",block_property.default.x)
					edit.set_meta(&"link",['value_changed',block_property.default.x,func(v,link_block):
						if not edit.visible:return
						if v is Vector2:v=v.x
						if v is float:edit.value=v
						var link_val=link_block.get_meta(&"value_%s"%str(val),Vector2.ZERO)
						if link_val is String:
							pass
						else:
							link_block.set_meta(&"value_%s"%str(val),Vector2(v,link_block.get_meta(&"value_%s"%str(val),Vector2.ZERO).y))
							edit.value=v
							])
							
					edit.size_flags_horizontal=Control.SIZE_EXPAND_FILL
					edit.owner=built_block
				if block_property.editable:
					var edit=SpinBox.new()
					edit.allow_greater=true
					edit.allow_lesser=true
					edit.step=0.01
					added_item.add_child(edit)
					edit.set_meta(&"reset_value",block_property.default.y)
					edit.set_meta(&"link",['value_changed',block_property.default.y,func(v,link_block):
						if not edit.visible:return
						if v is Vector2:v=v.y
						
						if v is float:edit.value=v
						
						if link_block.get_meta(&"value_%s"%str(val),Vector2.ZERO) is String:
							pass
						else:
							link_block.set_meta(&"value_%s"%str(val),Vector2(link_block.get_meta(&"value_%s"%str(val),Vector2.ZERO).x,v))
							edit.value=v
							])
							
					edit.size_flags_horizontal=Control.SIZE_EXPAND_FILL
					edit.owner=built_block
			TYPE_STRING:
				var edit=LineEdit.new()
				added_item.add_child(edit)
				edit.size_flags_horizontal=Control.SIZE_EXPAND_FILL
				edit.set_meta(&"link",['text_changed',block_property.default,func(v,link_block):
					if not edit.visible:return
					if v is String:
						while v.begins_with("("):
							v=v.trim_prefix("(")
						
						edit.text=v
					
					link_block.set_meta(&"value_%s"%str(val),v)])
				#edit.text=block_property.default
				edit.owner=built_block
			TYPE_PACKED_STRING_ARRAY:
				var edit=OptionButton.new()
				for item in len(block_property.default)-1:edit.add_item(block_property.default[item])
				added_item.add_child(edit)
				built_block.set_meta(&"value_%s"%str(val),block_property.default[len(block_property.default)-1]+block_property.default[0])
				edit.set_meta(&"link",['item_selected',block_property.default[0],func(v,link_block):
					if v is int:v=block_property.default[len(block_property.default)-1]+edit.get_item_text(v)
					
					link_block.set_meta(&"value_%s"%str(val),v)
					])
				
				edit.size_flags_horizontal=Control.SIZE_EXPAND_FILL
				edit.owner=built_block
			TYPE_BOOL:
				var edit=CheckBox.new()
				added_item.add_child(edit)
				edit.set_meta(&"link",['toggled',block_property.default,func(v,link_block):
					if not (v is bool):v=block_property.default
					link_block.set_meta(&"value_%s"%str(val),v)
					])
				edit.size_flags_horizontal=Control.SIZE_EXPAND_FILL
				edit.owner=built_block
		i+=1;val+=1
	built_block.set_meta(&"value_count",block.properties.size())
	var packed_block=PackedScene.new()
	packed_block.pack(built_block)
	built_nodes[block.name]=packed_block


##oh god the abominations i have done here
func _set(property, value):
	
	match Array(property.split("/")).pop_back():
		"block_count":
			block_list.resize(value)
			block_list=block_list.map(
				func(v):
				if v==null:
					return {
					"name":"",
					"category":"",
					"runnable":true,
					"type":'variable',
					"description":"",
					"properties":[]
					}
				return v
			)
			notify_property_list_changed()
		"properties_count":
			var id=int(property.split("/")[0].trim_prefix("block_"))
			block_list[id].properties.resize(value)
			block_list[id].properties=block_list[id].properties.map(
				func(v):
				if v==null:
					return {
					"name":"",
					"type":TYPE_INT,
					"editable":true,
					"connect_left":true,
					"connect_right":false,
					"default":0
					}
				return v
			)
			notify_property_list_changed()
	if property.ends_with("type"):notify_property_list_changed.call_deferred()
	if property.begins_with("block_") and not property.ends_with("_count"):
		var ind=int(
			property.trim_prefix("block_").split("/")[0]
			)
		var editing=block_list[ind]
		for i in property.count("/")-1:
			var cur_split=property.split("/")[i+1]
			if cur_split.contains("_"):
				var formatted=cur_split.split("_")[0]
				formatted= (formatted + "s") if not formatted.ends_with("y") else (formatted.trim_suffix("y")+"ies")
				if(int(cur_split.split("_")[1])):
					editing=editing[formatted][int(cur_split.split("_")[1])]
					continue
				cur_split=formatted
			editing=editing[cur_split]
		var ordered=Array(property.split("/"))
		var final=ordered.pop_back()
		var last_state=ordered.pop_back()
		if property.ends_with("count"):
			editing[final.trim_suffix("_count")].resize(value)
		if last_state.contains("_") and not last_state.contains("block_"):
			if editing is Array and not editing.has(final):
				editing[int(last_state.split("_")[1])][final]=value
				return
			else:
				editing[final]=value
				return
		if not property.ends_with("count"):
			editing[Array(property.split("/")).pop_back()]=value


##you thought that was all the abomination i can make? think again
func _get(property):
	match property:
		"block_count":
			return block_list.size()
	if property.begins_with("block_"):
		
		var ind=int(
			property.trim_prefix("block_").split("/")[0]
			)
		var editing=block_list[ind]
		for i in property.count("/")-1:
			var cur_split=property.split("/")[i+1]
			if cur_split.contains("_"):
				var formatted=cur_split.split("_")[0]
				formatted= (formatted + "s") if not formatted.ends_with("y") else (formatted.trim_suffix("y")+"ies")
				if(int(cur_split.split("_")[1])):
					editing=editing[formatted][int(cur_split.split("_")[1])]
					continue
				cur_split=formatted
			editing=editing[cur_split]
		var ordered=Array(property.split("/"))
		var final=ordered.pop_back()
		if property.ends_with("count"):
			return editing[final.trim_suffix("_count")].size()
		var last_state=ordered.pop_back()
		if last_state.contains("_") and not last_state.contains("block_"):
			var formatted=last_state.split("_")[0]
			if editing is Array:return editing[int(last_state.split("_")[1])][final]
			else:return editing[final]
		return editing[Array(property.split("/")).pop_back()]
	
	




func _get_property_list():
	var result=[]
	var list_of_types:Array=[]
	for i in TYPE_MAX:
		list_of_types.push_back(type_string(i))
	
	
	result.append(
		{
			&"name": "block_count",
			&"type": TYPE_INT,
			&"usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_ARRAY,
			&"hint": PROPERTY_HINT_NONE,
			&"hint_string": "",
			&"class_name": "block,block_",
		}
	)
	
	for block in block_list.size():
		result.append_array(
			[{
			&"name": "block_%s/name"%str(block),
			&"type": TYPE_STRING_NAME,
			&"hint":PROPERTY_HINT_PLACEHOLDER_TEXT,
			&"hint_string":" "
				
			},
			{
			&"name": "block_%s/category"%str(block),
			&"type": TYPE_STRING_NAME,
			&"hint":PROPERTY_HINT_PLACEHOLDER_TEXT,
			&"hint_string":"Default"
			},
			{
			&"name": "block_%s/runnable"%str(block),
			&"type": TYPE_BOOL,
			},
			{
			&"name": "block_%s/type"%str(block),
			&"type": TYPE_STRING,
			&"hint":PROPERTY_HINT_ENUM,
			&"hint_string":",".join(["variable","function","variablefunction"])
			},
			{
			&"name": "block_%s/description"%str(block),
			&"type": TYPE_STRING,
			&"hint":PROPERTY_HINT_MULTILINE_TEXT
			},
			{
			&"name": "block_%s/properties_count"%str(block),
			&"type": TYPE_INT,
			&"usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_ARRAY,
			&"hint":PROPERTY_HINT_NONE,
			&"hint_string": "",
			&"class_name": "property,block_%s/property_"%[str(block)],
				
			}
			]
		)
		
		
		for property in block_list[block].properties.size():
			if(block_list[block].properties[property]==null):continue
			result.append_array(
				[
					{
						&"name": "block_%s/property_%s/name"%[str(block),str(property)],
						&"type": TYPE_STRING,
						
					},
					{
						&"name": "block_%s/property_%s/type"%[str(block),str(property)],
						&"type": TYPE_INT,
						&"hint":PROPERTY_HINT_ENUM,
						&"hint_string":",".join(list_of_types)
						
					},
					{
						&"name": "block_%s/property_%s/editable"%[str(block),str(property)],
						&"type": TYPE_BOOL,
						&"hint":PROPERTY_HINT_NONE,
						
					},
					{
						&"name": "block_%s/property_%s/connect_left"%[str(block),str(property)],
						&"type": TYPE_BOOL,
						&"hint":PROPERTY_HINT_NONE,
						
					},
					{
						&"name": "block_%s/property_%s/connect_right"%[str(block),str(property)],
						&"type": TYPE_BOOL,
						&"hint":PROPERTY_HINT_NONE,
						
					},
					{
						&"name": "block_%s/property_%s/default"%[str(block),str(property)],
						&"type": block_list[block].properties[property].type,
						&"hint":PROPERTY_HINT_NONE,
						
					},
				]
			)
	
	return result

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
	if not built_nodes.has(name_of_block):return
	create_item_block(name_of_block)


func create_item_block(name_of_block,select:bool=true,attach_to:Node=null):
	var added_block=built_nodes[name_of_block].instantiate(PackedScene.GEN_EDIT_STATE_INSTANCE)
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
	
