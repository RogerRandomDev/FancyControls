@tool
extends RefCounted
#WARNING
#ANY CHANGES MADE TO FUNCTIONS BEING RE-COMPILED WILL BE OVERWRITTEN

func ExamplePullIn(item_node:AnimatedItem,item_index:float=0,total_items:float=1,container_info={}):
	
	var Div2 = item_index/total_items
	var ComposeVector4 = Vector2(0.0,Div2)
	item_node.chain_action(0,ComposeVector4,1.5,Tween.TRANS_SINE,true) #Position
	var ComposeVector6 = Vector2(Div2,0.0)
	item_node.chain_action(0,ComposeVector6,1.5,Tween.TRANS_SINE,true) #Position



