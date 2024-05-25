@tool
extends Node
class_name code_block_funcs



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
