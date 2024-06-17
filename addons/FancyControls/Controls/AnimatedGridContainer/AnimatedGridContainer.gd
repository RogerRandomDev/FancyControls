@tool
@icon("res://addons/FancyControls/Controls/AnimatedGridContainer/AnimatedGridContainer.png")
extends AnimatedContainer
class_name AnimatedGridContainer
## Grid container based on the [AnimatedContainer] for handling a grid with a known width or height.

## If the container grows vertically or horizontally
@export_enum("Vertical","Horizontal") var expand_direction:int=0:
	set(v):
		expand_direction=v
		_notification(NOTIFICATION_RESIZED)
## Spacing between item middles. If items overlap remember the spacing doesn't account for item size.
## You have to account for that in the spacing as well.
@export var item_spacing:Vector2=Vector2.ZERO:
	set(v):
		item_spacing=v
		_notification(NOTIFICATION_RESIZED)


func _update_spacings(animated:bool=true)->void:
	
	animated = animated and not Engine.is_editor_hint()
	if get_child_count()==0 or Engine.is_editor_hint():return
	
	var nodes_to_space=get_children()
	var node_count=nodes_to_space.size()
	var available_space=size*0.5
	
	for id in node_count:
		var target_position=get_target_position_for_item(id)+nodes_to_space[id].attached_item.size*0.5
		if not (animate_spacing and animated):
			nodes_to_space[id].global_position=target_position
		nodes_to_space[id].targeted_position=target_position
		
	#prevent an error from no tweened values


func _editor_fit_contents()->void:
	var nodes_to_space=get_children()
	var node_count=nodes_to_space.size()
	var offset=size*0.5
	for id in node_count:
		var target_position=get_target_position_for_item(id)
		nodes_to_space[id].global_position=target_position
		nodes_to_space[id].scale=Vector2.ONE
		

## returns the vector2 for where the given item id is placed.
## only returns correctly assuming [param id] is already within the items in the container.
func get_target_position_for_item(id:int)->Vector2:
	if item_spacing.x==0 or item_spacing.y==0 or size.x==0 or size.y==0:return Vector2.ZERO
	var node_count=get_child_count()
	var available_space=(size.x-border_padding.x*2 if expand_direction==0 else size.y-border_padding.y*2)
	var space_per_item=Vector2i((size-border_padding*2)/item_spacing)
	var used_item_space=(space_per_item.x if expand_direction==0 else space_per_item.y)
	var second_item_space=(space_per_item.y if expand_direction==0 else space_per_item.x)
	var target_position=Vector2(
		(available_space/used_item_space)*(id%used_item_space),
		int(id/used_item_space)*(item_spacing.y if expand_direction==0 else item_spacing.x)
	)
	if expand_direction==1:
		target_position=Vector2(target_position.y,target_position.x)
	target_position=(target_position+border_padding)+global_position
	return target_position
