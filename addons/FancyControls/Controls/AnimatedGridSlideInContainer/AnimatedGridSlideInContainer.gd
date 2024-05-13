@tool
@icon("res://addons/FancyControls/Controls/AnimatedGridSlideInContainer/AnimatedGridSlideInContainer.png")
extends AnimatedGridContainer
class_name AnimatedGridSlideInContainer

@export var slide_from_direction:Vector2=Vector2.UP:
	set(v):
		slide_from_direction=v
		_notification(NOTIFICATION_RESIZED)

@export var active:bool=false:
	set(v):
		active=v
		_notification(NOTIFICATION_RESIZED)





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
	target_position=(target_position+border_padding)+global_position+(size*slide_from_direction*float(!active))
	return target_position
