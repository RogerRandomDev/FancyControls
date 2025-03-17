@tool
extends RefCounted
#WARNING
#ANY CHANGES MADE TO FUNCTIONS BEING RE-COMPILED WILL BE OVERWRITTEN

func Example(item_node:AnimatedItem,item_index:float=0,total_items:float=1,container_info={},_external_variables={}):
	
	var Div2 = item_index/total_items
	var Mul6 = Div2*-6.28
	var Rotate7 = Vector2(0, -32).rotated(Mul6)
	var Add8 = Rotate7+container_info.item_origins[item_index]
	var Sub3 = container_info.item_origins[item_index]-Rotate7
	var RandomFloat9 = randf_range(0.25,0.5)
	item_node.chain_action(0,Sub3,RandomFloat9,Tween.TRANS_SINE,false) #Position
	item_node.chain_action(0,Add8,1.0,Tween.TRANS_ELASTIC,false) #Position
	pass
