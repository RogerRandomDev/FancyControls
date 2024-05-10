@tool
extends Control
class_name AnimatedContainer

##updates the box contents whenever a child node is added
@export var auto_update:bool=true

@export var animate_spacing:bool=true

@export var border_padding:Vector2=Vector2.ZERO:
	set(v):
		border_padding=v
		_notification(NOTIFICATION_RESIZED)

@export_group("item functionality")
@export var item_function_script:Script:
	set(v):
		item_function_script=v
		notify_property_list_changed()
var item_function_holder:Node=Node.new()







func _ready():
	if not Engine.is_editor_hint():
		item_function_holder.set_script(item_function_script)
		var is_auto=auto_update
		auto_update=false
		for child in get_children():
			child.position=Vector2.ZERO
			self.add_child(child,false)
		auto_update=is_auto
		_attach_signal_links()
	_update_spacings.call_deferred(false)
	


func _update_spacings(animated:bool=true)->void:pass

func _editor_fit_contents()->void:pass



## overriding the default to allow some custom stuff to be handled.
## if set to an internal child, it will be stored normally and not as an item to hold
func add_child(child:Node,internal:bool=false,internal_mode:Node.InternalMode=Node.INTERNAL_MODE_DISABLED)->void:
	if child is AnimatedItem or Engine.is_editor_hint() or internal:
		super.add_child(child,internal,internal_mode)
		if Engine.is_editor_hint():
			_editor_fit_contents()
		
		return
	var child_holder=AnimatedItem.new(self,child)
	if not Engine.is_editor_hint():attach_signals_to_item(child_holder)
	
	super.add_child(child_holder,internal,internal_mode)
	child_holder.owner=get_tree().get_edited_scene_root()











##basically just get_child()
func get_item(item_id:int=-1)->AnimatedItem:
	if item_id<0 or item_id>get_child_count()-1:return null
	return get_child(item_id)


func add_item(item:AnimatedItem,animate_position:bool=false)->void:
	if animate_position:
		var start_position=item.global_position
		#creates new version of the item to clear the old one out and ignore any tweens on it
		if item.get_parent()!=null:
			item.reparent(self,false)
		else:
			add_child(item)
		
		var ind=get_children().find(item)
		var child_position=get_target_position_for_item(ind)
		animate_item_from_position.call_deferred(item,start_position,child_position)
	else:
		add_child(item)
	attach_signals_to_item(item)

func swap_items(id_1:int,id_2:int)->void:
	if not(get_child_count()>id_1 and get_child_count()>id_2 and id_1>=0 and id_2>=0):return
	var first:AnimatedItem=get_child(id_1)
	var second:AnimatedItem=get_child(id_2)
	move_child(first,id_2)
	move_child(second,id_1)



func animate_item_from_position(item:AnimatedItem,from_position:Vector2,to_position:Vector2)->void:
	item.global_position=from_position
	item.targeted_position=to_position


func get_target_position_for_item(id:int)->Vector2:return Vector2.ZERO







##used to handle some events that are emitted
func _notification(what):
	match what:
		NOTIFICATION_CHILD_ORDER_CHANGED:
			#fancy stuff going on here.
			#made with this so you can stop it if you dont want it
			if auto_update:
				if Engine.is_editor_hint():_editor_fit_contents()
				else:_update_spacings.call_deferred()
		NOTIFICATION_RESIZED:
			if auto_update:
				if Engine.is_editor_hint():_editor_fit_contents()
				else:_update_spacings.call_deferred()



const item_actions:Array=[
	&"hovered",
	&"unhovered",
	&"focused",
	&"unfocused",
	&"input"
]
var hovered:StringName=&""
var unhovered:StringName=&""
var focused:StringName=&""
var unfocused:StringName=&""
var input:StringName=&""



func _get_property_list():
	var result=[]
	
	var script_funcs := ""
	if item_function_script != null and item_function_script is Script:
		script_funcs = ",".join(item_function_script.get_script_method_list().map(func(x): return x[&"name"]))
	result.append_array(
		item_actions.map(
			func (x): return {
				&"name": x,
				&"type": TYPE_STRING_NAME,
				&"usage": PROPERTY_USAGE_DEFAULT,
				&"hint": PROPERTY_HINT_ENUM_SUGGESTION,
				&"hint_string": script_funcs,
			}
		)
	)
	return result
##internal only, this handles linking the properties for signals to the functions being called
func _attach_signal_links()->void:
	if not (item_function_script is Script and item_function_script != null):return
	#loop all children and apply the linking to the items
	for item in get_children():
		if not item is AnimatedItem:continue
		attach_signals_to_item(item)

func attach_signals_to_item(item:AnimatedItem)->void:
	for sig in item.get_signal_list():
		if not ["mouse_entered","mouse_exited","focus_entered","focus_exited","gui_input"].has(sig.name):continue
		for con in item.get_signal_connection_list(sig.name):
			item.disconnect(sig.name,con.callable)
	if hovered!=&"":item.mouse_entered.connect(item_function_holder.call.bind(hovered,item))
	if unhovered!=&"":item.mouse_exited.connect(item_function_holder.call.bind(unhovered,item))
	if focused!=&"":item.focus_entered.connect(item_function_holder.call.bind(focused,item))
	if unfocused!=&"":item.focus_exited.connect(item_function_holder.call.bind(unfocused,item))
	if input!=&"":item.gui_input.connect(item_function_holder.call.bind(input,item))


