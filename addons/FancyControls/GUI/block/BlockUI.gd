@tool
extends GraphEdit
@onready  var code_funcs=code_block_funcs.new()


var undo:UndoRedo=UndoRedo.new()

var connection_map:Dictionary={}


# Called when the node enters the scene tree for the first time.
func _ready():
	
	$StartNode.set_meta(&"runnable",true)
	$StartNode.set_meta(&"type","function")
	$StartNode.set_meta(&"action","INITIALIZE")
	$StartNode.set_meta(&"value_0","run_item_if_seen_it_is_an_error")
	$StartNode.set_meta(&"type_0",TYPE_NIL)
	$StartNode.set_meta(&"value_1","item_node.global_position")
	$StartNode.set_meta(&"type_1",TYPE_VECTOR2)
	$StartNode.set_meta(&"value_2","item_node.scale")
	$StartNode.set_meta(&"type_2",TYPE_VECTOR2)
	$StartNode.set_meta(&"value_3","item_node.rotation")
	$StartNode.set_meta(&"type_3",TYPE_FLOAT)
	$StartNode.set_meta(&"value_4","item_index")
	$StartNode.set_meta(&"type_4",TYPE_INT)
	$StartNode.set_meta(&"value_5","total_items")
	$StartNode.set_meta(&"type_5",TYPE_INT)
	$StartNode.set_meta(&"value_count",4)
	$StartNode.set_meta(&"ignore_in_compile",true)
	
	$StartContainerNode.set_meta(&"runnable",false)
	$StartContainerNode.set_meta(&"type","function")
	$StartContainerNode.set_meta(&"action","INITIALIZE_CONTAINER")
	$StartContainerNode.set_meta(&"value_0","container_info.size")
	$StartContainerNode.set_meta(&"type_0",TYPE_VECTOR2)
	$StartContainerNode.set_meta(&"value_1","container_info.global_position")
	$StartContainerNode.set_meta(&"type_1",TYPE_VECTOR2)
	$StartContainerNode.set_meta(&"value_2","container_info.item_origins[item_index]")
	$StartContainerNode.set_meta(&"type_2",TYPE_VECTOR2)
	$StartContainerNode.set_meta(&"value_3","container_info.rotation")
	$StartContainerNode.set_meta(&"type_3",TYPE_FLOAT)
	$StartContainerNode.set_meta(&"value_count",4)
	$StartContainerNode.set_meta(&"ignore_in_compile",true)
	
	
	
	set_meta(&"func_name","unset_name")
	
	
	add_valid_connection_type(0,0)
	add_valid_connection_type(TYPE_FLOAT,TYPE_VECTOR2)
	add_valid_connection_type(TYPE_VECTOR2,TYPE_FLOAT)
	
	

func _input(event):
	if event is InputEventKey and event.as_text()=="Ctrl+Z" and event.is_pressed() and not event.is_echo():
		
		undo.undo()
	if event is InputEventKey and event.as_text()=="Ctrl+Shift+Z" and event.is_pressed() and not event.is_echo():
		undo.redo()
	
	


func generate_connection_map()->void:
	connection_map={}
	connections.map(map_connection)
func map_connection(connection)->void:
	var connection_data=connection_map.get(connection.from_node,[])
	connection_data.push_back(
		{
			"from":get_node(String(connection.from_node)),
			"to":get_node(String(connection.to_node)),
			"from_port":connection.from_port,
			"to_port":connection.to_port
		}
	)
	connection_map.set(connection.from_node,connection_data)



func _on_connection_request(from_node, from_port, to_node, to_port):
	
	undo.create_action("UndoConnection")
	undo.add_do_method(connection_request_logic.bind(from_node,from_port,to_node,to_port))
	undo.add_undo_method(disconnection_request_logic.bind(from_node,from_port,to_node,to_port))
	undo.commit_action()
	
func connection_request_logic(from_node,from_port,to_node,to_port):
	if code_funcs==null:code_funcs=code_block_funcs.new()
	generate_connection_map()
	#hide the editable section when it is set externally
	var from_block = get_block(from_node)
	var to_block = get_block(to_node)
	
	var node_port=to_block.get_child(to_block.get_input_port_slot(to_port))
	var connection_list=connection_map.get(from_node,[])
	
	#actions can only chain
	if from_block.get_meta(&"runnable") and from_port==0 and connection_list.any(check_from_connected.bind(from_block,from_port)):return
	if connection_list.any(check_to_connected.bind(to_block,to_port)):return
	
	var to_port_slot=to_block.get_input_port_slot(to_port)
	var from_port_slot=from_block.get_output_port_slot(from_port)
	if to_block.has_meta(&"SourceRef"):
		var ref = to_block.get_meta(&"SourceRef",null)
		if ref:ref.value_changed.call_deferred(to_block,to_port_slot,true)
	if from_block.has_meta(&"SourceRef"):
		var ref=from_block.get_meta(&"SourceRef",null)
		if ref:ref.value_changed.call_deferred(from_block,from_port_slot,true)
	
	
	
	if to_port_slot>0:
		to_block.set_meta(
			&"value_%s"%str(to_port_slot),
			get_port_value(from_node,from_block,from_port)
		)
		
	
	var check_methods=[
		str(from_block.get_meta(&"action")).to_lower()+"_connected",
		str(to_block.get_meta(&"action")).to_lower()+"_connected"
	]
	for method_name in check_methods:
		if not code_funcs.has_method(method_name):continue
		code_funcs.call_deferred(method_name,from_node,to_node,from_port,to_port,self)
	
	
	if node_port.get_child_count()>1:
		for child in range(1,node_port.get_child_count()):
			node_port.get_child(child).hide()
	if node_port.get_child_count()>1:node_port.get_child(1).hide()
	
	connect_node(from_node,from_port,to_node,to_port)


func get_block(block_name):
	return get_node_or_null(String(block_name))
func check_to_connected(from,to,to_port)->bool:
	return from.get("to",null)==to and from.get("to_port",-1) == to_port
func check_from_connected(from,to,to_port)->bool:
	return from.get("from",null)==to and from.get("from_port",-1) == to_port

func get_port_value(from_name:String,node_block,from_port:int)->String:
	return String(from_name)+"|value_%s"%node_block.get_output_port_slot(from_port) if not node_block.get_meta(&"type")=="variable" else String(from_name)+"|value_0"




func _on_disconnection_request(from_node, from_port, to_node, to_port):
	
	undo.create_action("UndoDisconnection")
	undo.add_do_method(disconnection_request_logic.bind(from_node,from_port,to_node,to_port))
	undo.add_undo_method(connection_request_logic.bind(from_node,from_port,to_node,to_port))
	undo.commit_action()


func disconnection_request_logic(from_node,from_port,to_node,to_port):
	generate_connection_map()
	
	var from_block = get_block(from_node)
	var to_block = get_block(to_node)
	
	var to_port_slot=to_block.get_input_port_slot(to_port)
	var node_port=to_block.get_child(to_port_slot)
	
	#hide the editable section when it is set externally
	to_block.emit_signal("disconnected_port",to_port_slot,node_port)
	
	if node_port.get_child_count()>1:
		for child in range(1,node_port.get_child_count()):
			node_port.get_child(child).show()
	disconnect_node(from_node,from_port,to_node,to_port)
	
	var source_ref=to_block.get_meta(&"SourceRef")
	if source_ref:source_ref.reset_value(to_block,
		to_port_slot,to_block.get_meta(&"runnable",false)
	)
	

	var check_methods=[
		str(from_block.get_meta(&"action")).to_lower()+"_disconnected",
		str(to_block.get_meta(&"action")).to_lower()+"_disconnected"
	]
	for method_name in check_methods:
		if not code_funcs.has_method(method_name):continue
		code_funcs.call_deferred(method_name,from_node,to_node,from_port,to_port,self)
	
	


func _on_delete_nodes_request(nodes):
	#to block removing the start node that is treated as the start for parsing
	var start_at=nodes.find(&"StartNode")
	if start_at>-1:nodes.remove_at(start_at)
	start_at=nodes.find(&"StartContainerNode")
	if start_at>-1:nodes.remove_at(start_at)
	
	undo.create_action("UndoDeleteNodes")
	
	
	for node in nodes:
		var grabbed = get_node(String(node))
		undo.add_undo_reference(grabbed)
		
		undo.add_undo_method(add_child.bind(grabbed))
		get_connection_list().map(func(v):if v.from_node==node||v.to_node==node:
			undo.add_do_method(disconnection_request_logic.bind(v.from_node,v.from_port,v.to_node,v.to_port))
			undo.add_undo_method(call_deferred.bind('connection_request_logic',v.from_node,v.from_port,v.to_node,v.to_port))
			)
		undo.add_do_method(
			undo_delete_method.bind(grabbed)
			)
		
	undo.commit_action.call_deferred()

func undo_delete_method(grabbed):
	await get_tree().process_frame
	call_deferred("remove_child",grabbed)



var current_selected_nodes:Array=[]

func _on_duplicate_nodes_request():
	for node in current_selected_nodes:
		if node.name=="StartNode" or node.name=="StartContainerNode":continue
		#need to create new nodes to keep functions working because they seem to hate lambdas connected to signals i guess
		


func _on_node_selected(node):
	current_selected_nodes.push_back(node)


func _on_node_deselected(node):
	current_selected_nodes.erase(node)


func _on_func_name_text_changed(new_text):
	set_meta(&"func_name",new_text)


func _on_begin_node_move():
	undo.create_action("UndoMoveNodes")
	for node in current_selected_nodes:
		undo.add_undo_property(node,"position_offset",node.position_offset)


func _on_end_node_move():
	for node in current_selected_nodes:
		undo.add_do_property(node,"position_offset",node.position_offset)
	undo.commit_action()


## because undo-redo is always a nice feature to have, this acts as the builder to call
## instead of add_child in the blocklist when creating one
func attach_node(child)->void:
	undo.create_action("UndoCreateNode")
	undo.add_do_reference(child)
	undo.add_do_method(add_child.bind(child))
	undo.add_undo_method(remove_child.bind(child))
	undo.add_undo_method(_on_node_deselected.bind(child))
	undo.commit_action()
