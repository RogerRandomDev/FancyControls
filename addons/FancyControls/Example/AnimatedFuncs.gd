extends Node
class_name AnimatedFuncs


func item_hovered_example(item:AnimatedItem)->void:
	item.targeted_scale+=Vector2(0.1,0.1)
	item.targeted_position-=Vector2(0,4).rotated(item.rotation)
func item_unhovered_example(item:AnimatedItem)->void:
	item.targeted_scale-=Vector2(0.1,0.1)
	item.targeted_position+=Vector2(0,4).rotated(item.rotation)




