@tool
extends GraphNode
class_name FACSGraphNode

signal disconnected_port(port:int,node:Object)

func _ready():
	tooltip_text=get_meta(&"action","NO_ACTION")+str(get_parent().get_children().find(self))


func get_json()->Dictionary:
	var json_out={
		"name":name,
		"action":get_meta(&"action",""),
		"parameters":[],
		"position":position_offset
	}
	var i=0;
	while has_meta("value_%s"%str(i)):
		var meta=get_meta("value_%s"%str(i),null)
		json_out.parameters.push_back({
			"value":meta,
			"type":get_meta("type_%s"%str(i),0)
		})
		i+=1
	return json_out

func load_from_json(json:Dictionary)->void:
	print(json)
	
