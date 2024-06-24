@tool
extends EditorPlugin



const MainPanel = preload("res://addons/FancyControls/GUI/scene/control.tscn")

var main_panel_instance
var import_plugin_animation
var import_plugin_group

func _enter_tree():
	initialize_resources()
	
	import_plugin_animation= load("res://addons/FancyControls/Importers/FACSVisImporter.gd").new()
	import_plugin_group= load("res://addons/FancyControls/Importers/FacsVisGroupImporter.gd").new()
	add_import_plugin(import_plugin_animation)
	add_import_plugin(import_plugin_group)
	
	
	main_panel_instance = MainPanel.instantiate()
	# Add the main panel to the editor's main viewport.
	EditorInterface.get_editor_main_screen().add_child(main_panel_instance)
	# Hide the main panel. Very much required.
	_make_visible(false)
	
	#this fixed nothing and i dont know why.
	#EditorInterface.get_editor_settings().set_setting("text_editor/behavior/files/auto_reload_scripts_on_external_change", true)
	#push_warning("(FACS ADDON): Force set the script editor to auto reload when changed to deal with compiler causing the \"newer on disk\" popup.")
	
	

func initialize_resources()->void:
	if !DirAccess.dir_exists_absolute("res://FACS"):
		DirAccess.make_dir_absolute("res://FACS")
	if !DirAccess.dir_exists_absolute("res://FACS/Editor/"):
		DirAccess.make_dir_absolute("res://FACS/Editor/")
	if !DirAccess.dir_exists_absolute("res://FACS/Compiled/"):
		DirAccess.make_dir_absolute("res://FACS/Compiled/")
	if !FileAccess.file_exists("res://FACS/FACSManager.res"):
		var fMan=FACSManagerResource.new()
		fMan.resave()
		
	




func _exit_tree():
	remove_import_plugin(import_plugin_animation)
	remove_import_plugin(import_plugin_group)
	import_plugin_animation=null
	import_plugin_group=null
	if main_panel_instance:
		main_panel_instance.queue_free()


func _has_main_screen():
	return true


func _make_visible(visible):
	if main_panel_instance:
		main_panel_instance.visible = visible
		get_editor_interface().distraction_free_mode=visible



func _get_plugin_name():
	return "FACS Animations"


func _get_plugin_icon():
	return EditorInterface.get_editor_theme().get_icon("Node", "EditorIcons")
