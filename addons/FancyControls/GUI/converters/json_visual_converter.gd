@tool
extends RefCounted
class_name FACSJson




static func convert_tree(graph:GraphEdit)->Dictionary:
	var node_list=graph.get_children()
	node_list.erase(graph.get_child(0))
	node_list.erase(graph.get_child(1))
	var converted_list=[]
	var compiled_list=[]
	var converted_connections=[]
	for node in node_list:
		var n=visual_node.new(node,graph)
		converted_list.push_back(n.get_json())
		compiled_list.push_back(n.get_compile_format_json(graph))
	for connection in graph.get_connection_list():
		converted_connections.push_back(
			{
				"from":graph.get_children().find(graph.get_node(String(connection.from_node))),
				"to":graph.get_children().find(graph.get_node(String(connection.to_node))),
				"from_port":connection.from_port,
				"to_port":connection.to_port
			}
		)
	
	return {"nodes":converted_list,"connections":converted_connections,"compiler_data":compiled_list}


##fixes issues when converting between json text and godot dictionaries making vectors and other types into strings
static func correct_variable_typing(value):
	if value is String and value.begins_with("("):value = str_to_var("Vector2"+value)
	return value


static func convert_json(json_data,graph:GraphEdit,blockList):
	for node in graph.get_children():
		if node.get_meta("action","").begins_with("INITIALIZE"):continue
		node.free()
	graph.clear_connections()
	
	
	for node_data in json_data.nodes:
		var node=blockList.create_item_block(node_data.name if not node_data.has("var_type") else node_data.var_type,false,graph)
		node.position_offset=str_to_var("Vector2"+node_data.position)
		(func():
			var i=0
			if node_data.type==0:
				node.set_meta(&"value_0",node_data["var_name"])
				var value=correct_variable_typing(node_data["value"])
				node.set_meta(&"value_1",value)
			
			while node_data.has("value_%s"%str(i)):
				var value=correct_variable_typing(node_data["value_%s"%str(i)])
				node.set_meta(&"value_%s"%str(i),value)
				i+=1
		).call()
	graph.current_selected_nodes=[]
	for connection in json_data.connections:
		var link_nodes={
			"from_node":StringName(graph.get_child(connection.from).name),
			"to_node":StringName(graph.get_child(connection.to).name),
			"from_port":connection.from_port,
			"to_port":connection.to_port
		}
		graph.call_deferred('emit_signal','connection_request',link_nodes.from_node,link_nodes.from_port,link_nodes.to_node,link_nodes.to_port)
	
