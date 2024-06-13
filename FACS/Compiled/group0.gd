@tool
extends RefCounted
#WARNING
#ANY CHANGES MADE TO FUNCTIONS BEING RE-COMPILED WILL BE OVERWRITTEN

func test(item_node:AnimatedItem,item_index:float=0,total_items:float=1,container_info={}):
	
	var output_data:Dictionary={'Positions':[],'Rotations':[],'Scales':[]}
	var Sub8 = total_items-item_index
	var Div10 = Sub8/total_items
	var Mul9 = Div10*6.28
	var Rotate7 = Vector2(0, -64).rotated(Mul9)
	var Add2 = Rotate7+container_info.item_origins[item_index]
	output_data.Positions.push_back({'goal':Add2,'duration':1.0,'tween_type':Tween.TRANS_QUINT})
	var VecName:Vector2=Vector2(0, -128)
	var Add3 = VecName+Add2
	output_data.Positions.push_back({'goal':Add3,'duration':2.0,'tween_type':Tween.TRANS_EXPO})
	
	return output_data


func test2(item_node:AnimatedItem,item_index:float=0,total_items:float=1,container_info={}):
	
	var output_data:Dictionary={'Positions':[],'Rotations':[],'Scales':[]}
	var Sub8 = total_items-item_index
	var Div10 = Sub8/total_items
	var Mul9 = Div10*6.28
	var Rotate7 = Vector2(0, -64).rotated(Mul9)
	var Add2 = Rotate7+container_info.item_origins[item_index]
	output_data.Positions.push_back({'goal':Add2,'duration':1.0,'tween_type':Tween.TRANS_QUINT})
	var VecName:Vector2=Vector2(0, -128)
	var Add3 = VecName+Add2
	output_data.Positions.push_back({'goal':Add3,'duration':2.0,'tween_type':Tween.TRANS_EXPO})
	
	return output_data


