@tool
extends GraphEdit
@onready  var code_funcs=code_block_funcs.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	$StartNode.set_meta(&"runnable",true)
	$StartNode.set_meta(&"type","function")
	$StartNode.set_meta(&"action","INITIALIZE")
	$StartNode.set_meta(&"value_0","run_item_if_seen_it_is_an_error")
	$StartNode.set_meta(&"value_1","item_node.global_position")
	$StartNode.set_meta(&"value_2","item_node.scale")
	$StartNode.set_meta(&"value_3","item_node.rotation")
	$StartNode.set_meta(&"value_4","item_index")
	$StartNode.set_meta(&"value_5","total_items")
	$StartNode.set_meta(&"value_count",4)
	
	$StartContainerNode.set_meta(&"runnable",false)
	$StartContainerNode.set_meta(&"type","function")
	$StartContainerNode.set_meta(&"action","INITIALIZE_CONTAINER")
	$StartContainerNode.set_meta(&"value_0","container_info.size")
	$StartContainerNode.set_meta(&"value_1","container_info.global_position")
	$StartContainerNode.set_meta(&"value_2","container_info.item_origins[item_index]")
	$StartContainerNode.set_meta(&"value_3","container_info.rotation")
	$StartContainerNode.set_meta(&"value_count",4)
	
	
	
	set_meta(&"func_name","unset_name")
	add_valid_connection_type(0,0)





func _on_connection_request(from_node, from_port, to_node, to_port):
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
	var node=get_node(String(to_node))
	if code_funcs.has_method(str(node.get_meta(&"action"))+"_connected"):
		code_funcs.call_deferred(node.get_meta(&"action")+"_connected",node,from_node,from_port,to_port,self)
	
	if node_port.get_child_count()>1:node_port.get_child(1).hide()
	
	connect_node(from_node,from_port,to_node,to_port)


func _on_disconnection_request(from_node, from_port, to_node, to_port):
	#hide the editable section when it is set externally
	var node_port=get_node(String(to_node)).get_child(get_node(String(to_node)).get_input_port_slot(to_port))
	get_node(String(to_node)).emit_signal("disconnected_port",to_port-int(node_port.get_parent().get_meta(&"runnable")),node_port)
	if node_port.get_child_count()>1:node_port.get_child(1).show()
	
	
	
	disconnect_node(from_node,from_port,to_node,to_port)
	


func _on_delete_nodes_request(nodes):
	#to block removing the start node that is treated as the start for parsing
	var start_at=nodes.find(&"StartNode")
	if start_at>-1:nodes.remove_at(start_at)
	start_at=nodes.find(&"StartContainerNode")
	if start_at>-1:nodes.remove_at(start_at)
	for node in nodes:
		var grabbed = get_node(String(node))
		get_connection_list().map(func(v):if v.from_node==node||v.to_node==node:disconnect_node(v.from_node,v.from_port,v.to_node,v.to_port))
		grabbed.queue_free()




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
