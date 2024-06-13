@tool
extends RefCounted
class_name BlockColoring


static func ChangePortType(node:GraphNode,slot:int,side:int,type:int)->void:
	node.set_meta(&"type_%s"%str(slot),type)
	match type:
		TYPE_FLOAT:
			if side%2==1 and node.is_slot_enabled_left(slot):
				node.set_slot_type_left(slot,type)
				node.set_slot_color_left(slot,Color('FFF169'))
			if side>1 and node.is_slot_enabled_right(slot):
				node.set_slot_type_right(slot,type)
				node.set_slot_color_right(slot,Color('FFF169'))
		TYPE_VECTOR2:
			if side%2==1 and node.is_slot_enabled_left(slot):
				node.set_slot_type_left(slot,type)
				node.set_slot_color_left(slot,Color('73ff73'))
			if side>1 and node.is_slot_enabled_right(slot):
				node.set_slot_type_right(slot,type)
				node.set_slot_color_right(slot,Color('73ff73'))
