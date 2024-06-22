@tool
extends VBoxContainer
@onready var group_tree:Tree=$Tree

@onready var manager=load("res://FACS/FACSManager.res")

var base_graph

func _ready():
	
	($"../../ChainChooseForGroup" as FileDialog).current_dir="res://FACS/Editor"
	group_tree.set_column_title(0,"Name")
	group_tree.set_column_title(1,"Method(Optional)")
	group_tree.set_column_title(2,"File Path")
	group_tree.set_column_title(3,"Compile")
	group_tree.set_column_expand_ratio(0,4.0)
	group_tree.set_column_expand_ratio(1,1.0)
	group_tree.set_column_expand_ratio(2,3.0)
	group_tree.set_column_expand_ratio(3,0.0)
	group_tree.set_column_expand(3,false)
	var root=group_tree.create_item()
	
	manager.load_from_data()
	
	load_from_manager.call_deferred()
	
	(func():
		base_graph=$"../MainBox/BlockUI".duplicate(DUPLICATE_GROUPS|DUPLICATE_SCRIPTS|DUPLICATE_SIGNALS|DUPLICATE_USE_INSTANTIATION)
		).call_deferred()
	

func load_from_manager()->void:
	group_tree.clear()
	group_tree.create_item()
	var group_list=manager.get_group_list()
	var root_item=group_tree.get_root()
	var n=0
	for group_name in group_list:
		var group_item=root_item.create_child()
		group_item.set_text(0,group_name)
		group_item.set_text_alignment(3,HORIZONTAL_ALIGNMENT_CENTER)
		group_item.set_meta(&"is_group",true)
		group_item.set_meta(&"group_name",group_name)
		
		var group_binds=manager.get_chains_in_group(group_name)
		var invalid_bindings=manager.get_invalid_bindings_in_group(group_name)
		for bind in group_binds:
			var bound_item:TreeItem=group_item.create_child()
			#so i can keep track of things in the item itself
			bound_item.set_meta(&"group_name",group_name)
			bound_item.set_meta(&"is_group",false)
			bound_item.set_meta(&"name",bind.binding_name)
			bound_item.add_button(3,load("res://addons/FancyControls/GUI/scene/Remove.svg"),2)
			bind.insert_data_in_treeitem(bound_item)
			
		#if invalid_bindings.find(true)<0:
		group_item.add_button(3,load("res://addons/FancyControls/GUI/Add.svg"),0,false,"Add Chain To Group")
		group_item.add_button(3,load("res://addons/FancyControls/GUI/AssetLib.svg"),1,false,"Compile Group")
		


func _on_tree_item_collapsed(item:TreeItem):
	var sub_items:int=item.get_child_count()
	
	item.set_text(3,"")
	item.set_custom_color(3,Color.WHITE)
	if not item.collapsed:return
	
	#does this to make sure you always know something is invalid in a given group
	for child in sub_items:
		if item.get_child(child).get_text(3)=="!":
			item.set_text(3,"!")
			item.set_custom_color(3,Color.RED)
			break
		
	
var prev_selected:TreeItem=null
#i use this so you have to double-click it to make it editable
func _on_tree_item_selected():
	var selected_column=group_tree.get_selected_column()
	
	if prev_selected!=null and not prev_selected==group_tree.get_selected():
		prev_selected.set_editable(0,false)
		#prev_selected.set_editable(1,false)
		prev_selected.set_editable(2,false)
	prev_selected=group_tree.get_selected()
	
	#path or name of a group function
	if [0,1].has(selected_column) and not (selected_column>0 and group_tree.get_selected().get_parent()==group_tree.get_root()):
		group_tree.get_selected().set_editable(selected_column,true)
	
##when pressed it should attempt to compile the group into a script file of the functions
func _on_tree1_button_clicked(item, column, id, mouse_button_index):
	pass # Replace with function body.


func _on_tree_item_edited():
	var group_changing:bool=prev_selected.get_meta(&"is_group")
	#when you are changing the name of a group itself
	if group_changing:
		var old_name=prev_selected.get_meta(&"group_name")
		var name_changed_successfully:bool=manager.change_group_name(old_name,prev_selected.get_text(0))
		if not name_changed_successfully:
			prev_selected.set_text(0,old_name)
		else:
			prev_selected.set_meta(&"group_name",prev_selected.get_text(0))
			for child in prev_selected.get_children():
				child.set_meta(&"group_name",prev_selected.get_text(0))
			
	else:
		if prev_selected.get_cell_mode(1)==TreeItem.CELL_MODE_RANGE:
			var changed_script_method=manager.change_group_binding_script_method(prev_selected.get_meta(&"group_name"),prev_selected.get_meta(&"linked_resource"),prev_selected.get_text(1).split(",")[prev_selected.get_range(1)])
		#now when you are changing an items contents within the groupings
		var name_changed_successfully:bool=manager.change_group_binding_name(prev_selected.get_meta(&"group_name"),prev_selected.get_meta(&"linked_resource"),prev_selected.get_text(0))
		if not name_changed_successfully:
			prev_selected.set_text(0,prev_selected.get_meta(&"name"))
		else:prev_selected.set_meta(&"name",prev_selected.get_text(0))
func _on_tree_item_activated():
	#checks when something is double-clicked
	#row 2 is for items that are paths.
	#it should pull out a dialog to select a file to use instead
	if group_tree.get_selected_column()==2 and not prev_selected.get_meta(&"is_group"):
		$"../../ChainChooseDialog".visible=true
	


func _on_chain_choose_dialog_file_selected(path):
	var linked_res=prev_selected.get_meta(&"linked_resource")
	linked_res.binding_link_path=path
	manager.rebind_path_on(prev_selected.get_parent().get_text(0),linked_res,path)
	prev_selected.set_text(2,path)
	if linked_res.is_binding_valid():
		prev_selected.set_text(3,"")
		prev_selected.set_custom_color(3,Color.WHITE)
		prev_selected.set_custom_color(2,Color.WHITE)
	if path.ends_with(".gd"):
		#why do they not document that you can do this?
		prev_selected.set_cell_mode(1,TreeItem.CELL_MODE_RANGE)
		var end_of_function_regex=RegEx.create_from_string("\\nfunc [0-z]+")
		var loading_script_contents=FileAccess.get_file_as_string(path)
		var outputs=end_of_function_regex.search_all(loading_script_contents)
		prev_selected.set_text(1,
			",".join(Array(outputs).map(func(v):return v.strings[0].trim_prefix("\nfunc ")))
		)
	else:
		prev_selected.set_cell_mode(1,TreeItem.CELL_MODE_STRING)
	


func _on_create_group_button_pressed():
	var n=0
	while not manager.create_group("group%s"%str(n)):n+=1
	load_from_manager()


func _on_remove_group_button_pressed():
	if group_tree.get_selected()==null or not group_tree.get_selected().get_parent()==group_tree.get_root():return
	manager.remove_group(group_tree.get_selected().get_text(0))
	load_from_manager()
	


func _on_tree_button_clicked(item, column, id, mouse_button_index):
	match id:
		0:
			group_tree.set_selected(item,3)
			$"../../ChainChooseForGroup".visible=true
			pass
		1:
			#compile grouping
			#FACSGroupCompiler.compile_group(item,base_graph,$"../MainBox/VBoxContainer/BlockList")
			FACSGroupCompiler.compile_group(item,base_graph,$"../MainBox/VBoxContainer/BlockList")
		2:
			#remove item button
			group_tree.set_selected(item,3)
			$"../../ConfirmationDialog2".visible=true

func _on_chain_choose_for_group_file_selected(path):
	var group_name=prev_selected.get_meta(&"group_name")
	var path_split=path.split("/")
	var bind_name=path_split[len(path_split)-1].split(".")[0]
	
	if not manager.check_facs_group_can_add(group_name,bind_name,path):return
	manager.bind_facs_to_group(
		group_name,
		bind_name,
		path
	)
	load_from_manager()



func _on_confirmation_remove_group_func_confirmed():
	manager.remove_chain_from_group(prev_selected.get_meta(&"group_name"),prev_selected.get_text(0))
	prev_selected.free()
	
	
