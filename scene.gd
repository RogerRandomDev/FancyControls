extends Control


func _input(event):
	if Input.is_key_pressed(KEY_0):
		$AnimatedBoxContainer.play_animation("ExamplePullIn")
