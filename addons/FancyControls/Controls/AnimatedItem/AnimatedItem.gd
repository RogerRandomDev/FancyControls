@tool
extends Control
class_name AnimatedItem
## The base item used by [AnimatedContainer] nodes and their subtypes.
## Contains the managing systems for its animating.

## The node that is contained within this [AnimatedItem]
var attached_item:Node
## The node that contains this [AnimatedItem].
## This node has to be a [AnimatedContainer] or one of its subtypes.
var connected_control:Node
## The position to animate the [AnimatedItem] to from the current position.
## Automatically animates when changed.
var targeted_position:Vector2:
	set(v):
		if Engine.is_editor_hint():return
		var travel_distance=(v-global_position).length()
		targeted_position=v
		if is_inside_tree():
			if _tween_position:_tween_position.kill()
			_tween_position=create_tween()
			_tween_position.tween_property(self,'global_position',targeted_position,sqrt(travel_distance/pixels_per_second))
		else:
			global_position=targeted_position
## The rotation to animate the [AnimatedItem] to from the current rotation.
## Automatically animates when changed.
var targeted_rotation:float:
	set(v):
		if Engine.is_editor_hint():return
		var travel_distance=abs(angle_difference(v,rotation))
		
		targeted_rotation=v
		if is_inside_tree():
			if _tween_rotation:_tween_rotation.kill()
			_tween_rotation=create_tween()
			#this is to make sure it takes the shortest path it can
			targeted_rotation=lerp_angle(rotation,targeted_rotation,1.0)
			
			_tween_rotation.tween_property(self,'rotation',targeted_rotation,sqrt(travel_distance/PI)*0.25)
			#_tween_rotation.tween_property(self,'rotation',targeted_rotation,0.25)
		else:
			rotation=targeted_rotation
		
## The scale to animate the [AnimatedItem] to from the current scale.
## Automatically animates when changed.
var targeted_scale:Vector2=Vector2.ONE:
	set(v):
		if Engine.is_editor_hint():return
		var travel_distance=(scale-v).length()
		targeted_scale=v
		if is_inside_tree():
			if _tween_scale:_tween_scale.kill()
			_tween_scale=create_tween()
			#this is to make sure it takes the shortest path it can
				#targeted_rotation=-(targeted_rotation-PI)
			_tween_scale.tween_property(self,'scale',targeted_scale,sqrt(travel_distance/scale_rate_per_second))
		else:
			scale=targeted_scale

##change this value to adjust how fast scaling occurs
var scale_rate_per_second:float=16.0
##change this value to adjust how fast the item moves to the chosen location when it is changed
var pixels_per_second:float=4608.0

var _tween_position:Tween
var _tween_rotation:Tween
var _tween_scale:Tween

func _init(connected_to:Node=null,attached_to:Node=null):
	#this line is so pre-build ones don't break when loading
	if connected_to==null and attached_to==null:
		return
	
	assert(attached_to is Control,"Node Attached to an Animated Container Item is not a Control")
	
	connected_control=connected_control
	attached_item=attached_to
	
	#attaches item to self as a child
	if attached_item!=null:
		if attached_item.get_parent():
			attached_item.reparent(self,false)
		else:
			add_child(attached_item)
		(attached_item as Control).resized.connect(attached_item_size_changed)
		attached_item_size_changed()
	
	size_flags_horizontal=Control.SIZE_SHRINK_CENTER
	size_flags_vertical=Control.SIZE_SHRINK_CENTER
	
	position.x=connected_to.size.x*0.5
	position.y=connected_to.size.y*0.5
	
	child_exiting_tree.connect(check_if_needed)
	
	
	bind_interaction_signals()

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




