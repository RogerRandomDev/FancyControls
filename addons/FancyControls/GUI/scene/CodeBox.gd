@tool
extends HBoxContainer

var converter=preload("res://addons/FancyControls/GUI/converters/visual_script_converter.gd").new()
@onready var animations_container=$VBoxContainer/Container

func reload_codeview()->void:
	var converted_view=converter.convert_visual($"../MainBox/BlockUI")
	$CodeEdit.text=converted_view.code.replace("%METHOD_NAME%",$"../MainBox/BlockUI".get_meta(&"func_name"))
	$CodeEdit.syntax_highlighter.clear_member_keyword_colors()
	for variable in converted_view.variables:
		$CodeEdit.syntax_highlighter.add_member_keyword_color(variable,Color("66ffd1"))
	
	var scr=GDScript.new()
	scr.source_code="@tool\nextends RefCounted\n"+converted_view.code.replace("%METHOD_NAME%",$"../MainBox/BlockUI".get_meta(&"func_name"))
	scr.reload()
	
	$VBoxContainer/Container/AnimatedRoundContainer.set_animation_group(scr)



func _on_play_anim_pressed():
	for container in animations_container.get_children():
		if not container is AnimatedContainer:continue
		var is_currently_playing:bool=false
		for item in container.get_children():
			if not item is AnimatedItem:continue
			item.manual_step=false
			if item._tween_position and item._tween_position.is_valid():
				is_currently_playing=true
				item._tween_position.play()
			if item._tween_rotation and item._tween_rotation.is_valid():
				is_currently_playing=true
				item._tween_rotation.play()
			if item._tween_scale and item._tween_scale.is_valid():
				is_currently_playing=true
				item._tween_scale.play()
		if not is_currently_playing:
			container._editor_fit_contents()
			container.play_animation(container.get_animation_list()[0])

func _on_pause_anim_pressed():
	for container in animations_container.get_children():
		if not container is AnimatedContainer:continue
		for item in container.get_children():
			if not item is AnimatedItem:continue
			item.manual_step=true
			if item._tween_position and item._tween_position.is_valid():item._tween_position.pause()
			if item._tween_rotation and item._tween_rotation.is_valid():item._tween_rotation.pause()
			if item._tween_scale and item._tween_scale.is_valid():item._tween_scale.pause()


func _on_step_anim_pressed():
	#so if you step it also pauses it for you
	_on_pause_anim_pressed()
	#step is currently hard set at 0.05 seconds
	#i'll add an input to change that value later
	
	#temp way to increase speed. press shift for x4 step rate
	var step_rate = 1+3*int(Input.is_key_pressed(KEY_SHIFT))
	
	for container in animations_container.get_children():
		if not container is AnimatedContainer:continue
		var is_currently_playing:bool=false
		for item in container.get_children():
			if not item is AnimatedItem:continue
			if item._tween_position and item._tween_position.is_valid():
				is_currently_playing=true
				item._tween_position.custom_step(0.05*step_rate)
			if item._tween_rotation and item._tween_rotation.is_valid():
				is_currently_playing=true
				item._tween_rotation.custom_step(0.05*step_rate)
			if item._tween_scale and item._tween_scale.is_valid():
				is_currently_playing=true
				item._tween_scale.custom_step(0.05*step_rate)
		#also done here so you can step and loop it
		if not is_currently_playing:
			container._editor_fit_contents()
			container.play_animation.call_deferred(container.get_animation_list()[0])
			


func _on_reset_anim_pressed():
	get_parent().get_parent().reset_editor_container_previews()
	for container in animations_container.get_children():
		if not container is AnimatedContainer:continue
		container.clear_animations()
		container.play_animation.call_deferred(container.get_animation_list()[0])
