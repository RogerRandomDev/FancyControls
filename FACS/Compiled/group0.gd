@tool
extends RefCounted
#WARNING
#ANY CHANGES MADE TO FUNCTIONS BEING RE-COMPILED WILL BE OVERWRITTEN


func item_hovered_example(item:AnimatedItem)->void:
	item.set_stacked_position(Vector2(0,-8),0.0625,Tween.TRANS_CIRC)
	item.set_stacked_scale(Vector2(1.25,1.25),0.125,Tween.TRANS_BACK)


