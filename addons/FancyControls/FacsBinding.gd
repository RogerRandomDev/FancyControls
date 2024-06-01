@tool
extends Resource
## used internally to manage the bindings data
## i could have just used a dictionary and more functions
## but this is cleaner to manage and puts more into separating purpose
## and allows me to focus on keeping it just more visually readable
class_name FACSGroupBinding
@export var binding_name:String
@export var binding_link_path:String
@export var binding_valid:bool=true

func _init(name:String,path:String):
	binding_name=name
	binding_link_path=path
	binding_valid=true

func is_binding_valid()->bool:
	binding_valid=FileAccess.file_exists(binding_link_path)
	return binding_valid

func insert_data_in_treeitem(item:TreeItem)->void:
	item.set_meta(&"linked_resource",self)
	
	item.set_text(0,binding_name)
	
	item.set_text(2,binding_link_path)
	item.set_custom_color(2,Color.RED if !binding_valid else Color.WHITE)
	item.set_tooltip_text(2,"Invalid Path" if !binding_valid else "")
	
	item.set_text(3,"!" if !binding_valid else "")
	item.set_custom_color(3,Color.RED if !binding_valid else Color.WHITE)
	item.set_tooltip_text(3,"Invalid Path" if !binding_valid else "")
	item.set_text_alignment(3,HORIZONTAL_ALIGNMENT_CENTER)

func get_arr_data()->Array:
	return [binding_name,binding_link_path]

