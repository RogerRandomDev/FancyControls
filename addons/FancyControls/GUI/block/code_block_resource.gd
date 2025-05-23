@tool
extends Resource
class_name CodeBlockResource

@export var BlockName:String=""
@export var BlockCategories:PackedStringArray=PackedStringArray([])
@export var CodeLine:String=""
@export var SwappableCodeLines:Dictionary={
	
}
@export var RunnableNode:bool=false
@export var Parameters:Array[CodeBlockParameters]=[]

const replace_type={
	TYPE_PACKED_STRING_ARRAY:TYPE_STRING
}

func _init() -> void:
	(func():
		for i in Parameters.size():
			Parameters[i]=Parameters[i].duplicate(true)
	).call_deferred()

func build_block():
	var block=FACSGraphNode.new()
	var current_part_index:int=0
	block.title=BlockName
	if RunnableNode:
		load_runnable_component(block)
	
	for part_index in Parameters.size():
		var part_resource = Parameters[part_index]
		part_resource.get_parts_for_block(block,part_index,part_index+int(RunnableNode))
		reset_value(block,part_index,RunnableNode)
	
	apply_metadata(block)
	#EditorInterface.get_inspector().edit(block)
	
	
	return block

func apply_metadata(block)->void:
	block.set_meta(&"action",BlockName)
	block.set_meta(&"type",",".join(BlockCategories))
	block.set_meta(&"runnable",RunnableNode)
	block.set_meta(&"SourceRef",self)
	
	block.set_meta("value_count",Parameters.size())

func load_runnable_component(built_block)->Control:
	var run_item=Label.new()
	run_item.text="RUN"
	built_block.add_child(run_item)
	built_block.set_slot_enabled_left(0,true)
	built_block.set_slot_enabled_right(0,true)
	built_block.set_slot_color_left(0,Color("ff7664"))
	built_block.set_slot_color_right(0,Color("ff7664"))
	return run_item


func load_code_line(node_data:Dictionary,node_index:int,graph:GraphEdit)->String:
	var use_type = node_data.get("type_0",0)
	var output_line=""
	
	if SwappableCodeLines && SwappableCodeLines.has(use_type):
		output_line=SwappableCodeLines[use_type]
	else:
		output_line = CodeLine
	var final_line=parse_line(
		output_line,node_data,node_index,graph
	)
	
	return final_line + "\n\t"

func parse_line(output_line,node_data,node_index,graph):
	var final_line = ""
	var split_line = output_line.split("%")
	
	for i in range(1,split_line.size(),2):
		var replace_segment = split_line[i].to_lower()
		var tokens = replace_segment.split("_")
		match tokens[0]:
			"varname":
				split_line[i]=node_data.get("action")+str(node_index)
			"param":
				
				var param_id="value_%s"%tokens[1]
				var ignore_rest = false
				var value_out=node_data.get(param_id)
				var is_variable:bool=false
				var typed_int=int(node_data["type_%s"%tokens[1]])
				var converting_from_type:int=node_data.get("type_%s"%tokens[1],-1)
				var attached_token = "" if tokens.size()<3 else tokens[2]
					
				while value_out is String and value_out.contains("|"):
					var path = value_out.split("|")
					var checking_node=graph.get_node(path[0])
					var node_obj=null
					
					if checking_node.has_meta("SourceRef"):node_obj =checking_node.get_meta("SourceRef",null)
					converting_from_type=checking_node.get_meta(
							"type_%s"%path[1].split("_")[1]
					)
					if checking_node.get("name").begins_with("Start"):
						value_out = checking_node.get_meta(path[1],null)
						
						ignore_rest = true
						is_variable = true
						break
					if node_obj!= null and node_obj.Parameters[int(path[1].split("_")[1])].PartOnSide==1 and not node_obj.Parameters[int(path[1].split("_")[1])].specialDefault:
						value_out = node_obj.BlockName + str(checking_node.get_meta("node_index",0))
						is_variable = true
						ignore_rest=true
						break
					else:
						value_out=graph.get_node(path[0]).get_meta(path[1],"")
				
					#print(value_out)
					#typed_int=checking_node.get_meta(path[1].replace("value","type"))
				if ignore_rest:
					var replaced=convert_value_type(value_out,typed_int,converting_from_type)
					value_out=replaced
				else:
					if replace_type.has(typed_int):typed_int=replace_type[typed_int]
					value_out=convert_value_type(value_out,typed_int,converting_from_type)
				value_out = str(value_out)
				if attached_token!=null and attached_token.begins_with(":"):
					value_out+="."+attached_token.trim_prefix(":")
				split_line[i]=value_out
	return  ''.join(split_line)

func reset_value(node:FACSGraphNode,value_id:int=-1,check_runnable:bool=false,force_typing:bool=false)->void:
	if value_id-int(check_runnable)<0:return
	var default = Parameters[value_id-int(check_runnable)].DefaultValue
	if default is PackedStringArray:default = default[0]
	var val_id=str(value_id+int(RunnableNode&&!check_runnable))
	node.set_meta(&"value_%s"%val_id,
		default if not force_typing else type_convert(default,node.get_meta(&"type_%s"%val_id))
	)
	
	value_changed(node,value_id,check_runnable)

func value_changed(node,value_id,check_runnable)->void:
	if node.get_parent()==null or Parameters.size()==0:return
	var param = Parameters[value_id]
	if param.extra_resets!=null:for param_id in param.extra_resets:
		
		var node_data = {}
		for meta_tag in node.get_meta_list():
			node_data[meta_tag.to_lower()]=node.get_meta(meta_tag)
		var final_out=parse_line(Parameters[param_id].specialDefault,node_data,node.get_parent().get_children().find(node),node.get_parent())
		
		node.set_meta(&"value_%s"%str(param_id+int(!check_runnable&&RunnableNode)),final_out)
		

func convert_value_type(value_out,typed_int,initial_type):
	var starting_type=typeof(value_out)
	
	#print(initial_type,",",typed_int)
	#if initial_type==typed_int:return value_out
	match(typed_int):
		TYPE_INT:
			
			if initial_type==TYPE_VECTOR2:return "%s.x"%value_out
		TYPE_FLOAT:
			if initial_type==TYPE_VECTOR2:return value_out.x if starting_type==TYPE_VECTOR2 else value_out+".x"
			return value_out
			
		TYPE_VECTOR2:
			if initial_type==TYPE_FLOAT:return "Vector2(%s,%s)"%[str(value_out if value_out else 0),str(value_out if value_out else 0)]
			if starting_type==TYPE_FLOAT:return "Vector2(%s,%s)"%[str(value_out),str(value_out)]
			if value_out is Vector2:
				value_out=var_to_str(value_out)
		TYPE_STRING:
			if initial_type==TYPE_PACKED_STRING_ARRAY:return value_out
	return value_out
	
