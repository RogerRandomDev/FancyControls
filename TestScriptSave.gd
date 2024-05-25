extends RefCounted
static func slide_down_to_side(item_node:AnimatedItem,item_index=0,total_items=1,container_info={}):
	var Add6 = container_info.item_origins[item_index].y+128.0
	var ComposeVector3 = Vector2(container_info.item_origins[item_index].x,Add6)
	var output_data:Dictionary={'Positions':[],'Rotations':[],'Scales':[]}
	output_data.Positions.push_back({'goal':ComposeVector3,'duration':1.0,'tween_type':Tween.TRANS_SINE})
	var Add7 = container_info.item_origins[item_index].x+128.0
	var ComposeVector8 = Vector2(Add7,Add6)
	output_data.Positions.push_back({'goal':ComposeVector8,'duration':1.0,'tween_type':Tween.TRANS_SINE})
	
	return output_data
