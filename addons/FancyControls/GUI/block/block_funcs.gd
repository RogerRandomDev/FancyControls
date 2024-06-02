@tool
extends Node
class_name code_block_funcs

#region value type getter. annoying code but it works for now.
##i'll improve it and move it later
const default_value_types={
	"item_node.rotation":TYPE_FLOAT,
	"item_node.position":TYPE_VECTOR2,
	"item_node.global_position":TYPE_VECTOR2,
	"item_node.scale":TYPE_VECTOR2,
	
}
func get_value_type(on_node:GraphNode,val:int=0):
	#loops until it hits the primary reference it is linked to
	var on_graph=on_node.get_parent()
	var out=on_node.get_meta("value%s"%(("_"+str(val)) if val>-1 else ""))
	var node=null
	var last_out=out
	var out_type=on_node.get_meta("type_%s"%str(val))
	while out is String and out.contains("|"):
		last_out=out
		var split_out=out.split("|")
		node=on_graph.get_node(split_out[0])
		if ["variable","variablefunction"].has(node.get_meta(&"type")):
			out=node.get_meta(&"var_name")
		else:out=node.get_meta(split_out[1])
		out_type=node.get_meta("type_"+last_out.split("|")[1].split("_")[1])
	
	if default_value_types.has(out):return default_value_types[out]
	if out_type == TYPE_INT:return TYPE_FLOAT
	return out_type
#endregion


func DecomposeVector_connected(self_node,from_node,from_port,to_port,graph):
	var node=graph.get_node(String(from_node))
	var port=node.get_output_port_slot(from_port)
	var val=node.get_meta(&"value_%s"%(str(port) if not node.get_meta(&"type").contains("variable") else "0"))
	if val==null:return
	self_node.set_meta(&"value_1",val+".x")
	self_node.set_meta(&"value_2",val+".y")
func Float_connected(self_node,from_node,from_port,to_port,graph):
	var node=graph.get_node(String(from_node))
	var port=node.get_output_port_slot(from_port)
	var val=node.get_meta(&"value_%s"%(str(port) if not node.get_meta(&"type").contains("variable") else "0"))
	if val==null:return
	self_node.set_meta(&"value_1",val)


func Add_connected(from_node,to_node,from_port,to_port,graph):
	var self_node=graph.get_node(String(to_node))
	var node=graph.get_node(String(from_node))
	var based_on=node if node.get_meta(&"action") =="Add" else self_node
	var added_vector:bool=false
	
	if based_on==self_node:
		var s_port=node.get_output_port_slot(from_port)-int(node.get_meta(&"runnable",false))
		var val=node.get_meta(&"type_%s"%str(s_port))
		var to_slot=based_on.get_input_port_slot(to_port)
		based_on.set_meta(&"connected_left_%s"%str(to_slot),max(based_on.get_meta(&"connected_left_%s"%str(to_slot),0)+1,0))
		node.set_meta(&"connected_right_%s"%str(s_port),max(node.get_meta(&"connected_right_%s"%str(s_port),0)+1,0))
		if val==TYPE_VECTOR2:added_vector=true
	else:
		var s_port=self_node.get_input_port_slot(to_port)-int(self_node.get_meta(&"runnable",false))
		var val=self_node.get_meta(&"type_%s"%str(s_port))
		
		var to_slot=based_on.get_output_port_slot(from_port)
		based_on.set_meta(&"connected_right_%s"%str(to_slot),max(based_on.get_meta(&"connected_right_%s"%str(to_slot),0)+1,0))
		self_node.set_meta(&"connected_left_%s"%str(s_port),max(self_node.get_meta(&"connected_left_%s"%str(s_port),0)+1,0))
		
		if val==TYPE_VECTOR2:added_vector=true
	
	
	if added_vector or get_value_type(based_on,2) == TYPE_VECTOR2 or get_value_type(based_on,1) == TYPE_VECTOR2 or get_value_type(based_on,0) == TYPE_VECTOR2:
		BlockColoring.ChangePortType(based_on,0,2,TYPE_VECTOR2)
		BlockColoring.ChangePortType(based_on,1,1,TYPE_VECTOR2)
		BlockColoring.ChangePortType(based_on,2,1,TYPE_VECTOR2)
	else:
		BlockColoring.ChangePortType(based_on,0,2,TYPE_FLOAT)
		BlockColoring.ChangePortType(based_on,1,1,TYPE_FLOAT)
		BlockColoring.ChangePortType(based_on,2,1,TYPE_FLOAT)




func Add_disconnected(from_node,to_node,from_port,to_port,graph):
	var self_node=graph.get_node(String(to_node))
	var node=graph.get_node(String(from_node))
	var based_on=node if node.get_meta(&"action") =="Add" else self_node
	
	if based_on==self_node:
		var s_port=node.get_output_port_slot(from_port)-int(node.get_meta(&"runnable",false))
		var to_slot=based_on.get_input_port_slot(to_port)
		based_on.set_meta(&"connected_left_%s"%str(to_slot),max(based_on.get_meta(&"connected_left_%s"%str(to_slot),0)-1,0))
		node.set_meta(&"connected_right_%s"%str(s_port),max(node.get_meta(&"connected_right_%s"%str(node.get_output_port_slot(s_port)),0)-1,0))
		
		
		BlockColoring.ChangePortType(based_on,to_slot,3,TYPE_FLOAT)
	else:
		var s_port=self_node.get_input_port_slot(to_port)-int(self_node.get_meta(&"runnable",false))
		var to_slot=based_on.get_output_port_slot(from_port)
		
		based_on.set_meta(&"connected_right_%s"%str(to_slot),max(based_on.get_meta(&"connected_right_%s"%str(to_slot),0)-1,0))
		self_node.set_meta(&"connected_left_%s"%str(s_port),max(self_node.get_meta(&"connected_left_%s"%str(s_port),0)-1,0))
		
		BlockColoring.ChangePortType(based_on,to_slot,3,TYPE_FLOAT)
		
	for value in based_on.get_meta(&"value_count"):
		if based_on.get_meta(&"connected_left_%s"%str(value),0)>0 or based_on.get_meta(&"connected_right_%s"%str(value),0)>0:continue
		
		BlockColoring.ChangePortType(based_on,value,3,TYPE_FLOAT)
	
	
	
	
	
	
	if get_value_type(based_on,2) == TYPE_VECTOR2 or get_value_type(based_on,1) == TYPE_VECTOR2 or get_value_type(based_on,0) == TYPE_VECTOR2:
		BlockColoring.ChangePortType(based_on,0,2,TYPE_VECTOR2)
		BlockColoring.ChangePortType(based_on,1,1,TYPE_VECTOR2)
		BlockColoring.ChangePortType(based_on,2,1,TYPE_VECTOR2)
	else:
		BlockColoring.ChangePortType(based_on,0,2,TYPE_FLOAT)
		BlockColoring.ChangePortType(based_on,1,1,TYPE_FLOAT)
		BlockColoring.ChangePortType(based_on,2,1,TYPE_FLOAT)
