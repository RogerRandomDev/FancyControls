extends Control





func _on_button_pressed():
	if $VBoxContainer/AnimatedBoxContainer.get_child_count()<=0:return
	$VBoxContainer/AnimatedBoxContainer2.add_item($VBoxContainer/AnimatedBoxContainer.get_item(0),true)


func _on_button_2_pressed():
	if $VBoxContainer/AnimatedBoxContainer2.get_child_count()<=0:return
	$VBoxContainer/AnimatedBoxContainer.add_item($VBoxContainer/AnimatedBoxContainer2.get_item(0),true)


func _on_button_3_pressed():
	if $VBoxContainer/HBoxContainer/AnimatedRoundContainer2.get_child_count()<=0:return
	$VBoxContainer/HBoxContainer/AnimatedRoundContainer.add_item($VBoxContainer/HBoxContainer/AnimatedRoundContainer2.get_item(0),true)


func _on_button_4_pressed():
	if $VBoxContainer/HBoxContainer/AnimatedRoundContainer.get_child_count()<=0:return
	$VBoxContainer/HBoxContainer/AnimatedRoundContainer2.add_item($VBoxContainer/HBoxContainer/AnimatedRoundContainer.get_item(0),true)
