@tool
@icon("res://addons/FancyControls/Controls/AnimatedBoxContainer/AnimatedBoxContainer.png")
extends AnimatedContainer
class_name AnimatedBoxContainer

@export_enum("Vertical","Horizontal") var box_direction:int=0





func _update_spacings(animated:bool=true)->void:
	_update_start_positions()
	animated = animated and not Engine.is_editor_hint()
	if get_child_count()==0:return
	
	
	var nodes_to_space=get_children()
	var node_count=nodes_to_space.size()
	var available_space=(size.x if box_direction==1 else size.y)
	var extra_spacing = (available_space/node_count)*0.5
	
	for id in node_count:
		var target_position=get_target_position_for_item(id)
		if not (animate_spacing and animated):
			nodes_to_space[id].global_position=target_position
		nodes_to_space[id].targeted_position=target_position
		nodes_to_space[id].targeted_scale=Vector2.ONE
	#prevent an error from no tweened values


func _editor_fit_contents()->void:
	var nodes_to_space=get_children()
	var node_count=nodes_to_space.size()
	var available_space=(size.x if box_direction==1 else size.y)
	var extra_spacing = (available_space/node_count)*0.5
	for id in node_count:
		var target_position=get_target_position_for_item(id)
		nodes_to_space[id].global_position=target_position
		nodes_to_space[id].scale=Vector2.ONE

func get_target_position_for_item(id:int)->Vector2:
	var node_count=get_child_count()
	var available_space=(size.x if box_direction==1 else size.y)
	var spaced_position=((available_space/node_count)*id)+((available_space/node_count)*0.5)
	var target_position=global_position
	if box_direction==1:
		target_position.x+=spaced_position
	else:
		target_position.y+=spaced_position
	return target_position

