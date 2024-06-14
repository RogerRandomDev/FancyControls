@tool
extends RefCounted
#WARNING
#ANY CHANGES MADE TO FUNCTIONS BEING RE-COMPILED WILL BE OVERWRITTEN

func chicken(item_node:AnimatedItem,item_index:float=0,total_items:float=1,container_info={}):
	
	var output_data:Dictionary={'Positions':[],'Rotations':[],'Scales':[]}
	var Sub6 = total_items-item_index
	var Div8 = Sub6/total_items
	var Mul7 = Div8*6.28
	var Rotate5 = Vector2(0, -64).rotated(Mul7)
	var Add2 = Rotate5+container_info.item_origins[item_index]
	output_data.Positions.push_back({'goal':Add2,'duration':0.13,'tween_type':Tween.TRANS_QUAD})
	var VecName:Vector2=Vector2(0, -128)
	var Add3 = VecName+Add2
	output_data.Positions.push_back({'goal':Add3,'duration':0.5,'tween_type':Tween.TRANS_EXPO})
	
	return output_data


func sandwich(item_node:AnimatedItem,item_index:float=0,total_items:float=1,container_info={}):
	
	var output_data:Dictionary={'Positions':[],'Rotations':[],'Scales':[]}
	var Div5 = item_index/total_items
	var Mul8 = container_info.size.x*2.0
	var Mul3 = Div5*Mul8
	var Mul6 = Mul8*0.25
	var Sub7 = Mul3-Mul6
	var Add9 = Sub7+container_info.global_position.x
	var ComposeVector10 = Vector2(Add9,container_info.global_position.y)
	output_data.Positions.push_back({'goal':ComposeVector10,'duration':2.0,'tween_type':Tween.TRANS_LINEAR})
	
	return output_data


