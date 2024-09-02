@tool
extends Control
class_name AnimatedContainer
## Base container class for handling all AnimatedContainer related needs.
## Stores the basic info for what is used by them all.


## updates the box contents whenever a child node is added
@export var auto_update:bool=true

## if the contained items will animate or not
@export var animate_spacing:bool=true


## the added space from the edge for all contained items
@export var border_padding:Vector2=Vector2.ZERO:
	set(v):
		border_padding=v
		_notification(NOTIFICATION_RESIZED)

@export_group("item functionality")
## the animation group script, can be done by hand as long as functions match the required inputs
@export var animation_group:GDScript:
	set=set_animation_group

##the script that contains the functions that will be used by the contained [AnimatedItem] nodes
@export var item_function_script:Script:
	set(v):
		item_function_script=v
		notify_property_list_changed()
var _item_function_holder:Node=Node.new()

var item_origin_positions:Array=[]

var animations:RefCounted




func set_animation_group(animation_group_new:GDScript):
	if animations==null:animations=RefCounted.new()
	animations.set_script(animation_group_new)
	if animation_group_new==animation_group:return
	animation_group=animation_group_new

## honestly this is just here for the one person who inevitably asks for it.
## also because the editor uses it to know what the function name is in the preview.
func get_animation_list():
	return animations.get_script().get_script_method_list().map(func(v):return v.name)
##because yes
func play_animation(animation_name:String)->void:
	clear_animations()
	animate_items_with_chain(animation_name)

##hmmm i love overwriting data
func clear_animations()->void:
	for child in get_children():
		if not child is FancyAnimatedItem:continue
		child=child as FancyAnimatedItem
		child.target_chains={"position":[],"rotation":[],"scale":[]}
		if child._tween_position:
			child._tween_position.kill()
			child._tween_position=null
		if child._tween_rotation:
			child._tween_rotation.kill()
			child._tween_rotation=null
		if child._tween_scale:
			child._tween_scale.kill()
			child._tween_scale=null
	

func _ready():
	if not Engine.is_editor_hint():
		_item_function_holder.set_script(item_function_script)
		var is_auto=auto_update
		auto_update=false
		for child in get_children():
			child.position=Vector2.ZERO
			self.add_child(child,false)
		auto_update=is_auto
		_attach_signal_links()
		_update_spacings.call_deferred(false)
	_update_start_positions(false)
	
##not sure how to optimize this but hopefully it comes eventually
func _update_start_positions(recalculate:bool=true)->void:
	item_origin_positions.resize(get_child_count())
	for i in get_child_count():
		item_origin_positions[i]= get_child(i).global_position if not recalculate else get_target_position_for_item(i)


func _update_spacings(animated:bool=true)->void:pass

func _editor_fit_contents()->void:pass



## Overriding the default to allow some custom stuff to be handled.
## If set to an internal child, it will be stored normally and not as an item to hold
func add_child(child:Node,internal:bool=false,internal_mode:Node.InternalMode=Node.INTERNAL_MODE_DISABLED)->void:
	if child is AnimatedItem or Engine.is_editor_hint() or internal:
		super.add_child(child,internal,internal_mode)
		if Engine.is_editor_hint():
			_editor_fit_contents()
		return
	var child_holder=FancyAnimatedItem.new(self,child)
	if not Engine.is_editor_hint():attach_signals_to_item(child_holder)
	
	super.add_child(child_holder,internal,internal_mode)
	child_holder.owner=get_tree().get_edited_scene_root()











## Basically just get_child()
func get_item(item_id:int=-1)->AnimatedItem:
	if item_id<0 or item_id>get_child_count()-1:return null
	return get_child(item_id)

## Specialized version of [method add_child] that allows the item added to be reparented
## if it was already connected to anything. [param animate_position] will make the item
## animate itself from where it was to where it should be.
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


## Swaps the items at position [param id_1] and [param id_2].
## Is animated if [member animate_spacing] is set to true.
func swap_items(id_1:int,id_2:int)->void:
	if not(get_child_count()>id_1 and get_child_count()>id_2 and id_1>=0 and id_2>=0):return
	var first:AnimatedItem=get_child(id_1)
	var second:AnimatedItem=get_child(id_2)
	move_child(first,id_2)
	move_child(second,id_1)


## used to make the items move forwards by putting the last item in the first item position
func shift_items_forward()->void:
	if get_child_count()<1:return
	move_child(get_child(get_child_count()-1),0)
## reverse of [method shift_items_forward] where it pushes items from the first spot to the last
## to let them cycle
func shift_items_back()->void:
	if get_child_count()<1:return
	move_child(get_child(0),get_child_count()-1)



## Makes [AnimatedItem] move from the [param from_position] to [param to_position]
func animate_item_from_position(item:AnimatedItem,from_position:Vector2,to_position:Vector2)->void:
	item.global_position=from_position
	item.targeted_position=to_position

## Used by containers based on this for getting where the [AnimatedItem] nodes place themselves
func get_target_position_for_item(id:int)->Vector2:return Vector2.ZERO


func animate_items_with_chain(chain_name:String)->void:
	var scr=animations
	var container_data={
		"size":size,
		"global_position":global_position,
		"item_origins":item_origin_positions,
		"rotation":rotation
	}
	#var bound_call:Callable=
	for i in get_child_count():
		var child=get_child(i)
		scr.call(chain_name,child,i,get_child_count(),container_data)
		
		#if response == null:continue
		#this code is bad.
		#this is not high in my list of priorities yet.
		#probably going to update the editor itself to compile the calls to chain directly.
		#would save on everything.
		#for p in response.Positions:child.chain_action(0,p.get("goal"),p.get("duration"),p.get("tween_type"))
		#for p in response.Rotations:child.chain_action(1,p.get("goal"),p.get("duration"),p.get("tween_type"))
		#for p in response.Scales:child.chain_action(2,p.get("goal"),p.get("duration"),p.get("tween_type"))
	





#used to handle some events that are emitted
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


##the actions linked to the [AnimatedItem] nodes in the containers.
const item_actions:Array=[
	&"hovered",
	&"unhovered",
	&"focused",
	&"unfocused",
	&"input"
]
var _hovered:StringName=&""
var _unhovered:StringName=&""
var _focused:StringName=&""
var _unfocused:StringName=&""
var _input:StringName=&""



func _get_property_list():
	var result=[]
	
	var script_funcs := ""
	if item_function_script != null and item_function_script is Script:
		script_funcs = ",".join(item_function_script.get_script_method_list().map(func(x): return x[&"name"]))
	result.append_array(
		item_actions.map(
			func (x): return {
				&"name": "_"+x,
				&"type": TYPE_STRING_NAME,
				&"usage": PROPERTY_USAGE_DEFAULT,
				&"hint": PROPERTY_HINT_ENUM_SUGGESTION,
				&"hint_string": script_funcs,
			}
		)
	)
	return result
#internal only, this handles linking the properties for signals to the functions being called
func _attach_signal_links()->void:
	if not (item_function_script is Script and item_function_script != null):return
	#loop all children and apply the linking to the items
	for item in get_children():
		if not item is AnimatedItem:continue
		attach_signals_to_item(item)
##used internally to connect the signal functions to the [AnimatedItem] nodes
func attach_signals_to_item(item:AnimatedItem)->void:
	for sig in item.get_signal_list():
		if not ["mouse_entered","mouse_exited","focus_entered","focus_exited","gui_input"].has(sig.name):continue
		for con in item.get_signal_connection_list(sig.name):
			item.disconnect(sig.name,con.callable)
	if _hovered!=&"":item.mouse_entered.connect(_item_function_holder.call.bind(_hovered,item))
	if _unhovered!=&"":item.mouse_exited.connect(_item_function_holder.call.bind(_unhovered,item))
	if _focused!=&"":item.focus_entered.connect(_item_function_holder.call.bind(_focused,item))
	if _unfocused!=&"":item.focus_exited.connect(_item_function_holder.call.bind(_unfocused,item))
	if _input!=&"":item.gui_input.connect(_item_function_holder.call.bind(_input,item))


