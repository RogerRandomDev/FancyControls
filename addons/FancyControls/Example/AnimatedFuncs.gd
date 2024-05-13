extends Node
class_name AnimatedFuncs


func item_hovered_example(item:AnimatedItem)->void:
	item.targeted_scale+=Vector2(0.1,0.1)
func item_unhovered_example(item:AnimatedItem)->void:
	item.targeted_scale-=Vector2(0.1,0.1)




