extends Node
class_name AnimatedFuncs


func item_hovered_example(item:AnimatedItem)->void:
	item.manual_scale+=Vector2(0.1,0.1)
	item.manual_move-=Vector2(0,4)
func item_unhovered_example(item:AnimatedItem)->void:
	item.manual_scale-=Vector2(0.1,0.1)
	item.manual_move+=Vector2(0,4)




