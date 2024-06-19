@tool
extends RefCounted
class_name FACSVISCompiler



static func convert_node(node:GraphNode,graph:GraphEdit):
	var chain=[]
	var connections=graph.get_connection_list().filter(func(v):
		return v.to_node==node.name)
	
	for connection in connections:
		chain.append_array(convert_node(graph.get_node(String(connection.from_node)),graph))
	chain.push_back(node.name)
	return chain

static func convert_chain_to_code(chain:Array,graph,method_name:String=graph.get_meta(&"func_name"))->Dictionary:
	var code_out="func %METHOD_NAME%(item_node:AnimatedItem,item_index:float=0,total_items:float=1,container_info={}):\n\t\n\t"
	var final_chain=[]
	chain.map(func(v):if !final_chain.has(v):final_chain.push_back(v))
	chain=final_chain
	final_chain=[]
	var variable_list:PackedStringArray=PackedStringArray()
	for node in chain:
		var vis_node=visual_node.new(node,graph)
		if vis_node.is_variable():variable_list.push_back(vis_node.data.var_name)
			
		code_out+=vis_node.get_content()
	code_out+="pass\n"
	return {"code":code_out,"variables":variable_list}


static func convert_visual(graph:GraphEdit)->Dictionary:
	var connection_list:=graph.get_connection_list()
	var chains_to_start:Array=[]
	var runnable_nodes = graph.get_children().filter(func(v):return v.get_meta(&"runnable"))
	for connection in connection_list:
		chains_to_start.push_back(connection.to_node)
	var node_used=String(runnable_nodes[0].name)
	for node in graph.get_children():
		if not node.has_meta("type"):continue
		match node.get_meta("type"):
			"variable":
				node.set_meta(&"var_name",node.get_meta("value_0"))
			"variablefunction":
				node.set_meta(&"var_name",node.get_meta("action")+str(graph.get_children().find(node)))
	
	while true:
		var used=connection_list.filter(func(v):return String(v.from_node)==node_used and graph.get_node(String(v.to_node)).get_meta(&"runnable"))
		if used.size()==0:break
		node_used=String(used[0].to_node)
	var output=convert_chain_to_code(convert_node(graph.get_node(node_used),graph).map(func(v):return graph.get_node(String(v))),graph)
	
	
	
	
	return output

