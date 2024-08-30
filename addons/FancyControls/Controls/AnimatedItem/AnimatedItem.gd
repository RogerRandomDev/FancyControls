@tool
extends Control
class_name AnimatedItem
## The base item used by [AnimatedContainer] nodes and their subtypes.
## Contains the managing systems for its animating.
signal tweens_synced


## The node that is contained within this [AnimatedItem]
var attached_item:Node
## The node that contains this [AnimatedItem].
## This node has to be a [AnimatedContainer] or one of its subtypes.
var connected_control:Node

var manual_transformations:Control=Control.new()

var _pos_relative:bool=false
var _pos_travel_time:float=-1.0
var _rot_travel_time:float=-1.0
var _scale_travel_time:float=-1.0
var _pos_trans:int=0
var _rot_trans:int=0
var _scale_trans:int=0

var manual_step:bool=false
## setting it moves it based on the size of the container 0-1 being from container corner to container size
## also returns the 0-1 variation of position
var relative_position:Vector2:
	set(v):
		position=v*get_parent_control().size
	get:return position/get_parent_control().size


## The position to animate the [AnimatedItem] to from the current position.
## Automatically animates when changed.
var targeted_position:
	set(v):
		
		assert(v is Vector2)
		#if Engine.is_editor_hint():return
		if _pos_travel_time==-1:_pos_travel_time=get_pos_travel(v)
		targeted_position=v
		if is_inside_tree():
			var step_mode:bool=false
			if _tween_position:_tween_position.kill()
			_tween_position=create_tween()
			_tween_position.set_trans(_pos_trans)
			var pos_type='relative_position' if _pos_relative else 'global_position'
			
			_tween_position.tween_property(self,pos_type,targeted_position,_pos_travel_time)
			_tween_position.finished.connect(_param_tween_finished.bind("Pos"))
			_pos_travel_time=-1.0
			_pos_trans=Tween.TRANS_LINEAR
			if manual_step:_tween_position.pause()
		else:
			global_position=targeted_position
## The rotation to animate the [AnimatedItem] to from the current rotation.
## Automatically animates when changed.
var targeted_rotation=0.0:
	set(v):
		assert(v is float)
		#if Engine.is_editor_hint():return
		
		if _rot_travel_time==-1:_rot_travel_time=get_rot_travel(v)
		
		targeted_rotation=v
		if is_inside_tree():
			if _tween_rotation:_tween_rotation.kill()
			_tween_rotation=create_tween()
			_tween_rotation.set_trans(_rot_trans)
			#this is to make sure it takes the shortest path it can
			
			_tween_rotation.tween_property(self,'rotation',targeted_rotation,_rot_travel_time)
			_tween_rotation.finished.connect(_param_tween_finished.bind("Rot"))
			_rot_travel_time=-1.0
			_rot_trans=Tween.TRANS_LINEAR
			if manual_step:_tween_rotation.pause()
			#_tween_rotation.tween_property(self,'rotation',targeted_rotation,0.25)
		else:
			rotation=targeted_rotation
		
## The scale to animate the [AnimatedItem] to from the current scale.
## Automatically animates when changed.
var targeted_scale=Vector2.ONE:
	set(v):
		assert(v is Vector2)
		#if Engine.is_editor_hint():return
		if _scale_travel_time==-1:_scale_travel_time=get_scale_travel(v)
		
		targeted_scale=v
		if is_inside_tree():
			if _tween_scale:_tween_scale.kill()
			_tween_scale=create_tween()
			_tween_scale.set_trans(_scale_trans)
			#this is to make sure it takes the shortest path it can
				#targeted_rotation=-(targeted_rotation-PI)
				
			_tween_scale.tween_property(self,'scale',targeted_scale,_scale_travel_time)
			_tween_scale.finished.connect(_param_tween_finished.bind("Scl"))
			_scale_travel_time=-1.0
			_scale_trans=Tween.TRANS_LINEAR
			if manual_step:_tween_scale.pause()
		else:
			scale=targeted_scale

##change this value to adjust how fast scaling occurs
var scale_rate_per_second:float=16.0
##change this value to adjust how fast the item moves to the chosen location when it is changed
var pixels_per_second:float=4608.0


var _tween_position:Tween
var _tween_rotation:Tween
var _tween_scale:Tween

var _tween_manual_position:Tween
var _tween_manual_rotation:Tween
var _tween_manual_scale:Tween

func set_stacked_scale(new_scale:Vector2,over_duration:float=0.0,tween_type:Tween.TransitionType=Tween.TRANS_LINEAR)->void:
	if _tween_manual_scale!=null:
		_tween_manual_scale.kill()
	_tween_manual_scale=manual_transformations.create_tween()
	_tween_manual_scale.tween_property(manual_transformations,"scale",new_scale,over_duration).set_trans(tween_type)
func set_stacked_position(new_position:Vector2,over_duration:float=0.0,tween_type:Tween.TransitionType=Tween.TRANS_LINEAR)->void:
	if _tween_manual_position!=null:
		_tween_manual_position.kill()
	_tween_manual_position=manual_transformations.create_tween()
	_tween_manual_position.tween_property(manual_transformations,"position",new_position,over_duration).set_trans(tween_type)
func set_stacked_rotation(new_rotation:float,over_duration:float=0.0,tween_type:Tween.TransitionType=Tween.TRANS_LINEAR)->void:
	if _tween_manual_rotation!=null:
		_tween_manual_rotation.kill()
	_tween_manual_rotation=manual_transformations.create_tween()
	_tween_manual_rotation.tween_property(manual_transformations,"rotation",new_rotation,over_duration).set_trans(tween_type)

func _get(property):
	if property.begins_with("stacked"):
		return manual_transformations.get(property.trim_prefix('stacked_'))

func _set(property, value):
	if property.begins_with("stacked"):
		call("set_%s"%property,value)
		return true
	return false 





func get_pos_travel(to)->float:
	var travel_distance=(to-global_position).length()
	return sqrt(travel_distance/pixels_per_second)
func get_rot_travel(to)->float:
	var travel_distance=abs(angle_difference(to,rotation))
	if abs(targeted_rotation)<PI*2 and sign(targeted_rotation)!=sign(to):
		targeted_rotation=lerp_angle(rotation,targeted_rotation,1.0)
	return sqrt(travel_distance/PI)*0.25
func get_scale_travel(to)->float:
	var travel_distance  = (scale-to).length()
	return sqrt(travel_distance/scale_rate_per_second)

func _init(connected_to:Node=null,attached_to:Node=null):
	#cause yes
	add_child(manual_transformations)
	for child in get_children():if not child==manual_transformations:child.reparent(manual_transformations,false)
	
	#this line is so pre-build ones don't break when loading
	if connected_to==null and attached_to==null:
		return
	assert(attached_to is Control,"Node Attached to an Animated Container Item is not a Control")
	
	connected_control=connected_control
	attached_item=attached_to
	
	
	#attaches item to manual_transformations as a child
	if attached_item!=null:
		if attached_item.get_parent():
			attached_item.reparent(manual_transformations,false)
		else:
			manual_transformations.add_child(attached_item)
		(attached_item as Control).resized.connect(attached_item_size_changed)
		attached_item_size_changed()
	
	size_flags_horizontal=Control.SIZE_SHRINK_CENTER
	size_flags_vertical=Control.SIZE_SHRINK_CENTER
	
	position.x=connected_to.size.x*0.5
	position.y=connected_to.size.y*0.5
	
	child_exiting_tree.connect(check_if_needed)
	bind_interaction_signals()



##used to allow syncing up the animations
func _param_tween_finished(param_name)->void:
	match param_name:
		"Pos":if _tween_position:
			_tween_position.kill()
			_tween_position=null
		"Rot":if _tween_rotation:
			_tween_rotation.kill()
			_tween_rotation=null
		"Scl":if _tween_scale:
			_tween_scale.kill()
			_tween_scale=null
	
	if(
		(_tween_position==null or not _tween_position.is_valid()) and
		(_tween_rotation==null or not _tween_rotation.is_valid()) and 
		(_tween_scale==null or not _tween_scale.is_valid())
	):
		
		emit_signal.call_deferred("tweens_synced")



## binds the signals from the [member attached_item] to emit from self to allow the [member connected_control]
## to recieve them and process them accordingly based on its [member AnimatedContainer.item_actions]
func bind_interaction_signals()->void:
	if attached_item == null:return
	attached_item.mouse_entered.connect(emit_signal.bind("mouse_entered"))
	attached_item.mouse_exited.connect(emit_signal.bind("mouse_exited"))
	attached_item.focus_entered.connect(emit_signal.bind("focus_entered"))
	attached_item.focus_exited.connect(emit_signal.bind("focus_exited"))


func _enter_tree():
	targeted_position=global_position


## checks that it still has an attached item in the tree
## and frees itself if it finds none
func check_if_needed(value)->void:
	if value==attached_item and (value==null or value.is_queued_for_deletion()):
		queue_free()


## emited when the item contained changes size.
## recenters the contained item in self
func attached_item_size_changed()->void:
	if attached_item==null:return
	attached_item.position=-attached_item.size*0.5
	attached_item.pivot_offset=attached_item.size*0.5

func get_content_meta(meta_name:String,default)->Variant:
	if has_meta(meta_name):return get_meta(meta_name,default)
	return connected_control.get_meta(meta_name,default)






