extends Control




func _on_button_pressed():
	if $AnimatedBoxContainer.get_child_count()<=0:return
	$AnimatedBoxContainer2.add_item_from_position($AnimatedBoxContainer.get_item(0))


func _on_button_2_pressed():
	if $AnimatedBoxContainer2.get_child_count()<=0:return
	$AnimatedBoxContainer.add_item_from_position($AnimatedBoxContainer2.get_item(0))


func _on_button_3_pressed():
	if $AnimatedRoundContainer2.get_child_count()<=0:return
	$AnimatedRoundContainer.add_item_from_position($AnimatedRoundContainer2.get_item(0))


func _on_button_4_pressed():
	if $AnimatedRoundContainer.get_child_count()<=0:return
	$AnimatedRoundContainer2.add_item_from_position($AnimatedRoundContainer.get_item(0))
