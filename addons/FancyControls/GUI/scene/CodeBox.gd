@tool
extends HBoxContainer

var converter=preload("res://addons/FancyControls/GUI/converters/visual_script_converter.gd").new()


func reload_codeview()->void:
	var converted_view=converter.convert_visual($"../MainBox/BlockUI")
	$CodeEdit.text=converted_view.code
	$CodeEdit.syntax_highlighter.clear_member_keyword_colors()
	for variable in converted_view.variables:
		$CodeEdit.syntax_highlighter.add_member_keyword_color(variable,Color("66ffd1"))
	
