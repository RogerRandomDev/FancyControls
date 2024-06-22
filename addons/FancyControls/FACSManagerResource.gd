@tool
extends Resource
class_name FACSManagerResource

var Groups:Dictionary={}
@export var group_data:Dictionary={}

func _init():
	resource_name=&"FACSManagerStored"

func load_from_data():
	for group in group_data:
		Groups[group]=[]
		group_data[group].map(func(v):
			if len(v)>2:
				Groups[group].push_back(FACSGroupBinding.new(v[0],v[1],v[2]))
			else:
				Groups[group].push_back(FACSGroupBinding.new(v[0],v[1]))
			)


##will return false only if the group can't be created with a given name
func create_group(group_name:String)->bool:
	#regex magic is fun when it comes in handy. just prevents special characters mostly.
	if RegEx.create_from_string("\"(?:\\\\.|[^\"])*\"").search(group_name)!=null:return false
	if group_name.contains(" "):return false
	if Groups.has(group_name):return false
	var g=Groups.duplicate()
	g.merge({group_name:[]})
	Groups=g
	resave.call_deferred()
	return true

func remove_group(group_name:String):
	if not Groups.has(group_name):return
	Groups.erase(group_name)
	
	resave.call_deferred()





func change_group_name(old_name:String,new_name:String)->bool:
	
	if !Groups.has(old_name):return false
	if RegEx.create_from_string("[^A-Za-z0-9_]").search(new_name)!=null:return false
	if new_name.contains(" "):return false
	if Groups.has(new_name):return false
	var new_group={new_name:Groups[old_name]}
	var g=Groups.duplicate()
	
	g.merge(new_group)
	g.erase(old_name)
	Groups=g
	resave.call_deferred()
	return true

func change_group_binding_name(group_name:String,on_resource:FACSGroupBinding,new_name:String)->bool:
	
	if !Groups.has(group_name):return false
	if RegEx.create_from_string("[^A-Za-z0-9_]").search(new_name)!=null:return false
	if new_name.contains(" "):return false
	if Groups[group_name].any(func(v):return v.binding_name==new_name):return false
	var option=Groups[group_name].filter(func(v):return v.binding_name==on_resource.binding_name and v.binding_link_path==on_resource.binding_link_path)
	
	if len(option)==0:return false
	option[0].binding_name=new_name
	
	
	
	resave.call_deferred()
	
	return true


func change_group_binding_script_method(group_name:String,on_resource:FACSGroupBinding,new_method:String)->bool:
	if !Groups.has(group_name):return false
	var option=Groups[group_name].filter(func(v):return v.binding_name==on_resource.binding_name and v.binding_link_path==on_resource.binding_link_path)
	
	if len(option)==0:return false
	option[0].binding_special_data=new_method
	
	
	
	resave.call_deferred()
	
	return true

##returns a [PackedStringArray] of the names of all groups
func get_group_list()->Array:
	return Groups.keys()

##returns the content of the given group_name, defaults null if group does not exist
func get_chains_in_group(group_name:String):
	return Groups.get(group_name)


##returns the list of groups containing any invalid/non-existent function links
func get_invalid_groups()->PackedStringArray:
	var invalidGroups:PackedStringArray=PackedStringArray()
	for group in Groups.keys():
		pass
	return invalidGroups

##returns an array of booleans listing what are/are not valid bindings to a group
func get_invalid_bindings_in_group(group_name:String)->Array[bool]:
	if !Groups.has(group_name):return []
	var arr:Array[bool]=[]
	Groups[group_name].map(func(v:FACSGroupBinding):arr.push_back(v.is_binding_valid()))
	
	return arr

##checks the given bind_name and bind_path can be added properly to the given group_name
func check_facs_group_can_add(group_name:String,bind_name:String,bind_path:String)->bool:
	if !Groups.has(group_name):return false
	return not Groups[group_name].any(func(v):return v.binding_name==bind_name)

## creates a binding for the given path with the given name if it can
func bind_facs_to_group(group_name:String,bind_name:String,bind_path:String)->void:
	if !Groups.has(group_name):return
	var bind=FACSGroupBinding.new(bind_name,bind_path)
	Groups[group_name].push_back(bind)
	resave.call_deferred()

func rebind_path_on(group_name:String,on_resource,new_path:String)->void:
	if !Groups.has(group_name):return
	var option=Groups[group_name].filter(func(v):return v.binding_name==on_resource.binding_name and v.binding_link_path==on_resource.binding_link_path)
	if len(option)==0:return
	option[0].binding_link_path=new_path


func remove_chain_from_group(group_name:String,chain_name:String)->void:
	if !Groups.has(group_name):return
	var option=Groups[group_name].filter(func(v):return v.binding_name==chain_name)
	if len(option)==0:return
	Groups[group_name].erase(option[0])
	resave.call_deferred()

func resave():
	group_data={}
	for group in Groups:
		group_data[group]=[]
		for res in Groups[group]:
			group_data[group].push_back(res.get_arr_data())
	
	ResourceSaver.save(self,"res://FACS/FACSManager.res")
