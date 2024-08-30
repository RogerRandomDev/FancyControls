@tool
extends Resource
class_name visual_node

var on_graph:GraphEdit
enum nodeTypes{
	Variable,
	Function,
	VariableFunction
}

var data={
	
}

var link_node

func _init(node,graph)->void:
	
	on_graph=graph
	link_node=node
	if not node.has_meta("type"):
		data={'type':-1}
	else:
		match node.get_meta("type"):
			"variable":
				data={
					"type":nodeTypes.Variable,
					"name":node.get_meta(&"value_0"),
					"var_name":node.get_meta(&"value_0"),
					"var_type":node.get_meta(&"action"),
					"value":node.get_meta(&"value_1"),
				}
			"function":
				data={
					"type":nodeTypes.Function,
					"name":node.get_meta(&"action"),
				}
				for value in node.get_meta(&"value_count"):
					data['value_%s'%str(value)]=node.get_meta(&"value_%s"%str(value))
			"variablefunction":
				data={
					"type":nodeTypes.VariableFunction,
					"name":node.get_meta(&"action"),
					"var_name":node.get_meta(&"action")+str(on_graph.get_children().find(node)),
					'value':node.get_meta(&"action")+str(on_graph.get_children().find(node)),
				}
				for value in node.get_meta(&"value_count"):
					data['value_%s'%str(value)]=node.get_meta(&"value_%s"%str(value))
				for type in node.get_meta_list().filter(func(v):return v.begins_with("type_")):
					data[type]=node.get_meta(type)
	

func is_variable()->bool:return data.type==nodeTypes.Variable or data.type==nodeTypes.VariableFunction


const default_value_types={
	"item_node.rotation":TYPE_FLOAT,
	"item_node.position":TYPE_VECTOR2,
	"item_node.global_position":TYPE_VECTOR2,
	"item_node.scale":TYPE_VECTOR2,
	
}

func convert_value_type(value,to_type:int=TYPE_NIL,on_node:GraphNode=null):
	if value is int:value = float(value)
	var cur_type=typeof(value)
	if value is String and not to_type==TYPE_STRING:
		if default_value_types.has(String(value)):
			cur_type=default_value_types[value]
		else:
			if String(value).begins_with("Tween."):
				cur_type=TYPE_INT
			else:
				if on_node and on_node.has_meta(value):
					cur_type=typeof(on_node.get_meta(value))
	match to_type:
		TYPE_FLOAT:
			if(cur_type==TYPE_VECTOR2):
				return value.x if not value is String else value+".x"
		TYPE_VECTOR2:
			if(cur_type==TYPE_FLOAT):
				return "Vector2(%s,%s)"%[str(value),str(value)]
	return value
	


func get_value(val:int=0,val_type:int=TYPE_NIL):
	var out=data.get("value%s"%(("_"+str(val)) if val>-1 else ""))
	#loops until it hits the primary reference it is linked to
	var node=null
	while out is String and out.contains("|"):
		var split_out=out.split("|")
		node=on_graph.get_node(split_out[0])
		if ["variable","variablefunction"].has(node.get_meta(&"type")):
			out=node.get_meta(&"var_name")
		else:out=node.get_meta(split_out[1])
	return var_to_str(convert_value_type(out,val_type,node)).replace("\"","")


func get_function_content()->String:
	match data.name:
		"INITIALIZE":
			return "";
		"INITIALIZE_CONTAINER":
			return ""
		"Add":
			return "var %s = %s+%s\n\t"%[data.value,get_value(1,data['type_1']),get_value(2,data['type_2'])]
		"Sub":
			return "var %s = %s-%s\n\t"%[data.value,get_value(1,data['type_1']),get_value(2,data['type_2'])]
		"Mul":
			return "var %s = %s*%s\n\t"%[data.value,get_value(1,data['type_1']),get_value(2,data['type_2'])]
		"Div":
			return "var %s = %s/%s\n\t"%[data.value,get_value(1,data['type_1']),get_value(2,data['type_2'])]
		"Min":
			return "var %s = min(%s,%s)\n\t"%[data.value,get_value(1,TYPE_FLOAT),get_value(2,TYPE_FLOAT)]
		"Max":
			return "var %s = max(%s,%s)\n\t"%[data.value,get_value(1,TYPE_FLOAT),get_value(2,TYPE_FLOAT)]
		"Floor":
			return "var %s = %s\n\t"%[data.value,"floor(%s)"%get_value(1,data['type_1']) if data['type_1']==TYPE_FLOAT else "%s.floor()"%get_value(1,data['type_1'])]
		"Ceil":
			return "var %s = %s\n\t"%[data.value,"ceil(%s)"%get_value(1,data['type_1']) if data['type_1']==TYPE_FLOAT else "%s.ceil()"%get_value(1,data['type_1'])]
		"Abs":
			return "var %s = %s\n\t"%[data.value,"abs(%s)"%get_value(1,data['type_1']) if data['type_1']==TYPE_FLOAT else "%s.abs()"%get_value(1,data['type_1'])]
		"Rotate":
			return "var %s = %s.rotated(%s)\n\t"%[data.value,get_value(1,TYPE_VECTOR2),get_value(2,TYPE_FLOAT)]
		"DecomposeVector":
			return ""
		"ComposeVector":
			return "var %s = Vector2(%s,%s)\n\t"%[data.value,get_value(1,TYPE_FLOAT),get_value(2,TYPE_FLOAT)]
		"SetPosition":
			return "item_node.chain_action(0,%s,%s,%s,%s) #Position\n\t"%[get_value(0,TYPE_VECTOR2),get_value(1,TYPE_FLOAT),get_value(2,TYPE_INT),get_value(3,TYPE_BOOL)]
		"SetRotation":
			return "item_node.chain_action(1,%s,%s,%s) #Rotation\n\t"%[get_value(0,TYPE_FLOAT),get_value(1,TYPE_FLOAT),get_value(2,TYPE_INT)]
		"SetScale":
			return "item_node.chain_action(2,%s,%s,%s) #Scale\n\t"%[get_value(0,TYPE_VECTOR2),get_value(1,TYPE_FLOAT),get_value(2,TYPE_INT)]
		"SyncParameters":
			return "item_node.sync_chains()\n\t"
			#return "output_data.Positions.push_back({'tween_type':-9});output_data.Rotations.push_back({'tween_type':-9});output_data.Scales.push_back({'tween_type':-9})\n\t"
	return ""


func get_content()->String:
	if not data.has("type"):return ""
	match data.type:
		nodeTypes.Variable:
			return "var %s:%s=%s\n\t"%[data.name,data.var_type.to_lower().capitalize().replace(" ",""),get_value(-1)]
		nodeTypes.Function:
			return get_function_content()
		nodeTypes.VariableFunction:
			return get_function_content()
	return ""

##gets the json that is used to rebuild a node structure when loading from the json
func get_json():
	var out=data.duplicate()
	out.position=link_node.position_offset
	return out

##compiles the value data directly to what it needs for use when compiling
func get_compile_format_json(graph_node:GraphEdit):
	var out={}
	var used_keys=data.keys().filter(func(v):return v.begins_with("value_"))
	for key in used_keys:
		var key_val=data[key]
		while key_val is String and key_val.contains("|"):
			key_val=graph_node.get_node(key_val.split("|")[0]).get_meta(key_val.split("|")[1])
		out[key]=key_val
	return out
