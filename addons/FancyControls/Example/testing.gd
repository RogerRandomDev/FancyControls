extends Control


func _ready():
	
	$FancyAnimatedItem.chain_action(
		FancyAnimatedItem.AnimatableTypes.POSITION,
		Vector2(0,256),
		1.0,
		Tween.TRANS_CUBIC
	)
	$FancyAnimatedItem.chain_action(
		FancyAnimatedItem.AnimatableTypes.POSITION,
		Vector2(256,256),
		1.0,
		Tween.TRANS_CUBIC
	)
	$FancyAnimatedItem._target_chains_updated("position")

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


func _on_toggle_slidein_pressed():
	$VBoxContainer/AnimatedGridSlideInContainer.active=!$VBoxContainer/AnimatedGridSlideInContainer.active


func _on_toggle_fromcenter_round_pressed():
	$VBoxContainer/HBoxContainer/AnimatedRoundContainer2.active=!$VBoxContainer/HBoxContainer/AnimatedRoundContainer2.active


func _on_cycle_left_pressed():
	$VBoxContainer/HBoxContainer/AnimatedRoundContainer.shift_items_forward()
func _on_cycle_left_back_pressed():
	$VBoxContainer/HBoxContainer/AnimatedRoundContainer.shift_items_back()





func _on_cycle_right_pressed():
	$VBoxContainer/HBoxContainer/AnimatedRoundContainer2.shift_items_forward()


func _on_cycle_right_bacck_pressed():
	$VBoxContainer/HBoxContainer/AnimatedRoundContainer2.shift_items_back()
