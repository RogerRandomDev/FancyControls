@tool
extends GraphNode
signal disconnected_port(port:int,node:Object)

func _ready():
	tooltip_text=get_meta(&"action","NO_ACTION")+str(get_parent().get_children().find(self))
