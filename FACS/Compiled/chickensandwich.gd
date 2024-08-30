@tool
extends RefCounted
#WARNING
#ANY CHANGES MADE TO FUNCTIONS BEING RE-COMPILED WILL BE OVERWRITTEN

func chicken(item_node:AnimatedItem,item_index:float=0,total_items:float=1,container_info={}):
	
	pass



func sandwich(item_node:AnimatedItem,item_index:float=0,total_items:float=1,container_info={}):
	
	var Div5 = item_index/total_items
	var Mul8 = container_info.size.x*2.0
	var Mul3 = Div5*Mul8
	var Mul6 = Mul8*0.25
	var Sub7 = Mul3-Mul6
	var Add9 = Sub7+container_info.global_position.x
	var ComposeVector10 = Vector2(Add9,container_info.global_position.y)
	item_node.chain_action(0,ComposeVector10,0.5,Tween.TRANS_QUART) #Position
	pass



