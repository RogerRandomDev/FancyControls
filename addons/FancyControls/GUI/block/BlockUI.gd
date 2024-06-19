@tool
extends GraphEdit
@onready  var code_funcs=code_block_funcs.new()


var undo:UndoRedo=UndoRedo.new()

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
	
	
	
	set_meta(&"func_name","unset_name")
	
	
	add_valid_connection_type(0,0)
	add_valid_connection_type(TYPE_FLOAT,TYPE_VECTOR2)
	add_valid_connection_type(TYPE_VECTOR2,TYPE_FLOAT)
	

func _input(event):
	if event is InputEventKey and event.as_text()=="Ctrl+Z" and event.is_pressed() and not event.is_echo():
		
		undo.undo()
	if event is InputEventKey and event.as_text()=="Ctrl+Shift+Z" and event.is_pressed() and not event.is_echo():
		undo.redo()
	
	




func _on_connection_request(from_node, from_port, to_node, to_port):
	undo.create_action("UndoConnection")
	undo.add_do_method(connection_request_logic.bind(from_node,from_port,to_node,to_port))
	undo.add_undo_method(disconnection_request_logic.bind(from_node,from_port,to_node,to_port))
	undo.commit_action()
func connection_request_logic(from_node,from_port,to_node,to_port):
	if code_funcs==null:code_funcs=code_block_funcs.new()
	
	#hide the editable section when it is set externally
	var node_port=get_node(String(to_node)).get_child(get_node(String(to_node)).get_input_port_slot(to_port))
	
	
	
	#actions can only chain
	if get_node(String(from_node)).get_meta(&"runnable") and from_port==0 and get_connection_list().filter(func(v):return v.from_node==from_node and v.from_port==0).size()!=0:return
	if get_connection_list().filter(func(v):return v.to_node==to_node and v.to_port==to_port).size()!=0:return
	if get_node(String(to_node)).get_input_port_slot(to_port)>0 or not get_node(String(from_node)).get_meta(&"runnable"):
		get_node(String(to_node)).set_meta(
			&"value_%s"%str(get_node(String(to_node)).get_input_port_slot(to_port)-int(get_node(String(to_node)).get_meta(&"runnable"))),
			String(from_node)+"|value_%s"%get_node(String(from_node)).get_output_port_slot(from_port)
			 if not get_node(String(from_node)).get_meta(&"type")=="variable" else String(from_node)+"|value_0"
		)
	var node=get_node(String(from_node))
	if code_funcs.has_method(str(node.get_meta(&"action"))+"_connected"):
		code_funcs.call_deferred(node.get_meta(&"action")+"_connected",from_node,to_node,from_port,to_port,self)
	if node_port.get_child_count()>1:
		for child in range(1,node_port.get_child_count()):
			node_port.get_child(child).hide()
		
	node.get_output_port_slot(from_port)
	
	node=get_node(String(to_node))
	if code_funcs.has_method(str(node.get_meta(&"action"))+"_connected"):
		code_funcs.call_deferred(node.get_meta(&"action")+"_connected",from_node,to_node,from_port,to_port,self)
	if node_port.get_child_count()>1:node_port.get_child(1).hide()
	node.get_input_port_slot(to_port)
	
	connect_node(from_node,from_port,to_node,to_port)


func _on_disconnection_request(from_node, from_port, to_node, to_port):
	
	undo.create_action("UndoDisconnection")
	undo.add_do_method(disconnection_request_logic.bind(from_node,from_port,to_node,to_port))
	undo.add_undo_method(connection_request_logic.bind(from_node,from_port,to_node,to_port))
	undo.commit_action()


func disconnection_request_logic(from_node,from_port,to_node,to_port):
	#needs fixed this still doesnt properly update the type of resource connected for ADD_connected and ADD_disconnected.
	#great pain fills me
	
	#hide the editable section when it is set externally
	var node_port=get_node(String(to_node)).get_child(get_node(String(to_node)).get_input_port_slot(to_port))
	get_node(String(to_node)).emit_signal("disconnected_port",get_node(String(to_node)).get_input_port_slot(to_port),node_port)
	
	if node_port.get_child_count()>1:
		for child in range(1,node_port.get_child_count()):
			node_port.get_child(child).show()
	disconnect_node(from_node,from_port,to_node,to_port)
	
	
	var node=get_node(String(from_node))
	
	if code_funcs.has_method(str(node.get_meta(&"action"))+"_disconnected"):
		code_funcs.call_deferred(node.get_meta(&"action")+"_disconnected",from_node,to_node,from_port,to_port,self)
	node=get_node(String(to_node))
	if code_funcs.has_method(str(node.get_meta(&"action"))+"_disconnected"):
		code_funcs.call_deferred(node.get_meta(&"action")+"_disconnected",from_node,to_node,from_port,to_port,self)
	
	


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






