@tool
@icon("res://addons/FancyControls/Controls/AnimatedRoundContainer/AnimatedRoundContainer.png")
extends AnimatedContainer
class_name AnimatedRoundContainer


@export_enum("Clockwise","CounterClockwise") var box_direction:int=0
@export var do_rotation:bool=true
@export var initial_rotation_degrees:float=0.0



func _ready():
	super._ready()
	if Engine.is_editor_hint():return
	initial_rotation_degrees=deg_to_rad(initial_rotation_degrees)


func _update_spacings(animated:bool=true)->void:
	_update_start_positions()
	animated = animated and not Engine.is_editor_hint()
	if get_child_count()==0:return
	
	var nodes_to_space=get_children()
	var node_count=nodes_to_space.size()
	var available_space=size*0.5
	
	for id in node_count:
		var target_position=get_target_position_for_item(id)
		var target_rotation=lerp_angle(nodes_to_space[id].targeted_rotation,(id/float(node_count))*PI*2*(box_direction*2-1)+initial_rotation_degrees,1.0)
		
		if not (animate_spacing and animated):
			nodes_to_space[id].global_position=target_position
			if do_rotation:nodes_to_space[id].rotation=target_rotation
		if do_rotation:nodes_to_space[id].targeted_rotation=target_rotation
		nodes_to_space[id].targeted_position=target_position
		nodes_to_space[id].targeted_scale=Vector2.ONE
	#prevent an error from no tweened values


func _editor_fit_contents()->void:
	var nodes_to_space=get_children()
	var node_count=nodes_to_space.size()
	var offset=size*0.5
	for id in node_count:
		var target_position=get_target_position_for_item(id)-nodes_to_space[id].size*0.5
		nodes_to_space[id].global_position=target_position
		nodes_to_space[id].scale=Vector2.ONE
		

func get_target_position_for_item(id:int)->Vector2:
	var node_count=get_child_count()
	var available_space=(size.x if box_direction==1 else size.y)
	var spaced_position=Vector2(0,-1).rotated((id/float(node_count))*PI*2*(box_direction*2-1)+initial_rotation_degrees)
	var target_position=(spaced_position*(size*0.5-border_padding)+size*0.5)+global_position
	return target_position
