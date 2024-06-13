@tool
extends RefCounted
class_name FACSGroupCompiler





static func _get_method_file_as_json(path):
	var file=FileAccess.open(path,FileAccess.READ)
	#decompress the file, the last 4 bytes are listing how big it should be after decompression
	var buffer=file.get_buffer(file.get_length())
	var buffer_size=buffer.decode_s32(len(buffer)-4)
	buffer.resize(len(buffer)-4)
	buffer=buffer.decompress(buffer_size,FileAccess.COMPRESSION_GZIP)
	var file_text=buffer.get_string_from_utf8()
	
	file.close()
	return JSON.parse_string(file_text)


static func compile_group(group_root:TreeItem,graph_base:GraphEdit,blocklist)->void:
	var script_contents="@tool\nextends RefCounted\n#WARNING\n#ANY CHANGES MADE TO FUNCTIONS BEING RE-COMPILED WILL BE OVERWRITTEN\n\n"
	
	
	
	
	for method_item in group_root.get_children():
		var temp_graph=graph_base.duplicate(Node.DUPLICATE_SCRIPTS|Node.DUPLICATE_SIGNALS|Node.DUPLICATE_USE_INSTANTIATION)
		var from_file=_get_method_file_as_json(method_item.get_text(2))
		FACSJson.convert_json(from_file,temp_graph,blocklist)
		await blocklist.get_tree().process_frame
		var compiled_vis_data=FACSVISCompiler.convert_visual(temp_graph)
		script_contents+=compiled_vis_data.code.replace("%METHOD_NAME%",method_item.get_text(0))+"\n\n\n"
	
	var group_name=group_root.get_text(0)
	
	var compiled_group=GDScript.new()
	compiled_group.source_code=script_contents
	
	ResourceSaver.save(compiled_group,"res://FACS/Compiled/%s.gd"%group_name)
	
