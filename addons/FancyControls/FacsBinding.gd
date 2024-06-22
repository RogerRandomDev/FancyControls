@tool
extends Resource
## used internally to manage the bindings data
## i could have just used a dictionary and more functions
## but this is cleaner to manage and puts more into separating purpose
## and allows me to focus on keeping it just more visually readable
class_name FACSGroupBinding
@export var binding_name:String
@export var binding_special_data:String
@export var binding_link_path:String
@export var binding_valid:bool=true

func _init(name:String,path:String,special:String=""):
	binding_name=name
	binding_special_data=special
	binding_link_path=path
	binding_valid=true

func is_binding_valid()->bool:
	binding_valid=FileAccess.file_exists(binding_link_path)
	return binding_valid

func insert_data_in_treeitem(item:TreeItem)->void:
	item.set_meta(&"linked_resource",self)
	
	item.set_text(0,binding_name)
	#this bit is for building the range select to choose the method for usage
	if binding_link_path.ends_with(".gd"):
		#why do they not document that you can do this?
		item.set_cell_mode(1,TreeItem.CELL_MODE_RANGE)
		var end_of_function_regex=RegEx.create_from_string("\\nfunc [0-z]+")
		var loading_script_contents=FileAccess.get_file_as_string(binding_link_path)
		var outputs=end_of_function_regex.search_all(loading_script_contents)
		item.set_text(1,
			",".join(Array(outputs).map(func(v):return v.strings[0].trim_prefix("\nfunc ")))
		)
	item.set_range(1,item.get_text(1).split(",").find(binding_special_data))
	item.set_editable(1,true)
	
	
	item.set_text(2,binding_link_path)
	item.set_custom_color(2,Color.RED if !binding_valid else Color.WHITE)
	item.set_tooltip_text(2,"Invalid Path" if !binding_valid else "")
	
	item.set_text(3,"!" if !binding_valid else "")
	item.set_custom_color(3,Color.RED if !binding_valid else Color.WHITE)
	item.set_tooltip_text(3,"Invalid Path" if !binding_valid else "")
	item.set_text_alignment(3,HORIZONTAL_ALIGNMENT_CENTER)

func get_arr_data()->Array:
	
	return [binding_name,binding_link_path,binding_special_data]

