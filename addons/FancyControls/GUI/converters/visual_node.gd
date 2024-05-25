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
					"value":node.get_meta(&"value_1")
				}
			"function":
				data={
					"type":nodeTypes.Function,
					"name":node.get_meta(&"action")
				}
				for value in node.get_meta(&"value_count"):
					data['value_%s'%str(value)]=node.get_meta(&"value_%s"%str(value))
			"variablefunction":
				data={
					"type":nodeTypes.VariableFunction,
					"name":node.get_meta(&"action"),
					"var_name":node.get_meta(&"action")+str(on_graph.get_children().find(node)),
					'value':node.get_meta(&"action")+str(on_graph.get_children().find(node))
				}
				for value in node.get_meta(&"value_count"):
					data['value_%s'%str(value)]=node.get_meta(&"value_%s"%str(value))


func is_variable()->bool:return data.type==nodeTypes.Variable or data.type==nodeTypes.VariableFunction

func get_value(val:int=0):
	var out=data.get("value%s"%(("_"+str(val)) if val>-1 else ""))
	#loops until it hits the primary reference it is linked to
	while out is String and out.contains("|"):
		var split_out=out.split("|")
		var node=on_graph.get_node(split_out[0])
		if ["variable","variablefunction"].has(node.get_meta(&"type")):
			out=node.get_meta(&"var_name")
		else:out=node.get_meta(split_out[1])
	return var_to_str(out).replace("\"","")


func get_function_content()->String:
	match data.name:
		"INITIALIZE":
			return "var output_data:Dictionary={'Positions':[],'Rotations':[],'Scales':[]}\n\t"
		"INITIALIZE_CONTAINER":
			return ""
		"Add":
			return "var %s = %s+%s\n\t"%[data.value,get_value(1),get_value(2)]
		"Sub":
			return "var %s = %s-%s\n\t"%[data.value,get_value(1),get_value(2)]
		"Mul":
			return "var %s = %s*%s\n\t"%[data.value,get_value(1),get_value(2)]
		"Div":
			return "var %s = %s/%s\n\t"%[data.value,get_value(1),get_value(2)]
		"DecomposeVector":
			return ""
		"ComposeVector":
			return "var %s = Vector2(%s,%s)\n\t"%[data.value,get_value(1),get_value(2)]
		"SetPosition":
			return "output_data.Positions.push_back({'goal':%s,'duration':%s,'tween_type':%s})\n\t"%[get_value(0),get_value(1),get_value(2)]
		"Rotate":
			return "var %s = %s.rotated(%s)\n\t"%[data.value,get_value(1),get_value(2)]
	
	return ""


func get_content()->String:
	if not data.has("type"):return ""
	match data.type:
		nodeTypes.Variable:
			return "var %s:%s=%s\n\t"%[data.name,data.var_type.to_lower(),get_value(-1)]
		nodeTypes.Function:
			return get_function_content()
		nodeTypes.VariableFunction:
			return get_function_content()
	return ""


func get_json():
	var out=data.duplicate()
	out.position=link_node.position_offset
	return out

