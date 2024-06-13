@tool
extends EditorImportPlugin


func _get_importer_name():
	return "FACS.Visual"

func _get_visible_name():
	return "FACS Visual Animation"

func _get_recognized_extensions():
	return ["facsvis"]

func _get_save_extension():
	return "res"

func _get_resource_type():
	return "Resource"

func _get_preset_count():
	return 1

func _get_priority():return 1
func _get_import_order():return 1

func _get_preset_name(preset_index):
	return "Default"

func _get_import_options(path, preset_index):
	return []

func _get_option_visibility(path, option_name, options):
	return true

func _import(source_file, save_path, options, r_platform_variants, r_gen_files):
	var file = FileAccess.open(source_file, FileAccess.READ)
	if file == null:
		return FileAccess.get_open_error()
	var resource=FACSVis.new()
	resource.binary_data=file.get_buffer(file.get_length())
	
	return ResourceSaver.save(resource,"%s.%s"%[save_path,_get_save_extension()])


