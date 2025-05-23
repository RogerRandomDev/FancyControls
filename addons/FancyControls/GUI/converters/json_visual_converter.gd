@tool
extends RefCounted
class_name FACSJson




static func convert_tree(graph:GraphEdit)->Dictionary:
	var node_list=graph.get_children()
	node_list=node_list.filter(func(a):return not ["StartNode","StartContainerNode","_connection_layer"].has(a.name))
	var converted_list=[]
	#var compiled_list=[]
	var converted_connections=[]
	for node in node_list:
		if not node is GraphNode:continue
		converted_list.push_back(node.get_json())
	for connection in graph.connections:
		converted_connections.push_back(
			{
				"from":String(connection.from_node),
				"to":String(connection.to_node),
				"from_port":connection.from_port,
				"to_port":connection.to_port
			}
		)
	
	#return {"nodes":converted_list,"connections":converted_connections,"compiler_data":compiled_list}
	return {"nodes":converted_list,"connections":converted_connections}


##fixes issues when converting between json text and godot dictionaries making vectors and other types into strings
static func correct_variable_typing(value):
	if value is String and value.begins_with("("):value = str_to_var("Vector2"+value)
	return value


static func convert_json(json_data,graph:GraphEdit,blockList):
	for node in graph.get_children():
		if node.get_meta("action","").begins_with("INITIALIZE") or node.name=="_connection_layer":continue
		node.queue_free()
	graph.clear_connections()
	await graph.get_tree().process_frame
	
	
	for node_data in json_data.nodes:
		var node=blockList.create_item_block(node_data.name if not node_data.has("action") else node_data.action,false,graph)
		node.name=node_data.name
		node.position_offset=str_to_var("Vector2"+node_data.position)
		(func():
			var i=0
			#if node_data.type==0:
				#node.set_meta(&"value_0",node_data["action"])
				#var value=correct_variable_typing(node_data["value"])
				#node.set_meta(&"value_1",value)
			
			while node_data.has("value_%s"%str(i)):
				var value=correct_variable_typing(node_data["value_%s"%str(i)])
				if value == null:
					var ref = node.get_meta(&"SourceRef")
					if ref!=null:
						ref.reset_value(node,i,false,true)
				node.set_meta(&"value_%s"%str(i),value)
				i+=1
		).call()
	graph.current_selected_nodes=[]
	for connection in json_data.connections:
		var link_nodes={
			"from_node":connection.from,
			"to_node":connection.to,
			"from_port":connection.from_port,
			"to_port":connection.to_port
		}
		graph.call_deferred('emit_signal','connection_request',link_nodes.from_node,link_nodes.from_port,link_nodes.to_node,link_nodes.to_port)
	
