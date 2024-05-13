@tool
extends AnimatedRoundContainer
class_name AnimatedFromCenterRoundContainer

@export var active:bool=false:
	set(v):
		active=v
		_notification(NOTIFICATION_RESIZED)






func get_target_position_for_item(id:int)->Vector2:
	var node_count=get_child_count()
	var available_space=(size.x if box_direction==1 else size.y)
	var spaced_position=Vector2(0,-1).rotated((id/float(node_count))*PI*2*(box_direction*2-1)+initial_rotation_degrees)*float(active)
	var target_position=(spaced_position*(size*0.5-border_padding)+size*0.5)+global_position
	return target_position
