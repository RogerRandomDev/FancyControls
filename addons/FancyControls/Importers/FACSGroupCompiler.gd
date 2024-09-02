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
	
	var end_of_function_regex=RegEx.create_from_string("\\nfunc [0-z]+")
	var end_of=RegEx.create_from_string("\\n[^\\t]+")
	
	for method_item in group_root.get_children():
		var file_path=method_item.get_text(2)
		#facsvis custom files
		if file_path.to_upper().ends_with("FACSVIS"):
			var temp_graph=graph_base.duplicate(Node.DUPLICATE_SCRIPTS|Node.DUPLICATE_SIGNALS|Node.DUPLICATE_USE_INSTANTIATION)
			var from_file=_get_method_file_as_json(file_path)
			FACSJson.convert_json(from_file,temp_graph,blocklist)
			await blocklist.get_tree().process_frame
			var compiled_vis_data=FACSVISCompiler.convert_visual(temp_graph)
			script_contents+=compiled_vis_data.code.replace("%METHOD_NAME%",method_item.get_text(0))+"\n\n\n"
		else:
			#normal gdscript function being used instead
			var loading_script_contents=FileAccess.get_file_as_string(file_path)
			var outputs=end_of_function_regex.search_all(loading_script_contents)
			var my_methods=method_item.get_text(1).split(",")
			for output in outputs:
				#chops the script to pull out only the wanted function code as text to use
				if output.strings[0].trim_prefix("\nfunc ")!=my_methods[method_item.get_range(1)]:continue
				var start_at=loading_script_contents.find(output.strings[0])
				var string_for=loading_script_contents.right(-start_at)
				var end_of_search=end_of.search_all(string_for)
				if len(end_of_search)>1:
					var end_at=string_for.find(end_of_search[1].strings[0])
					string_for=string_for.left(end_at)
				#to replace with the chosen name to use for this method
				string_for=string_for.replace(output.strings[0],"func %s"%method_item.get_text(0))
				script_contents+=string_for+"\n\n\n"
	var group_name=group_root.get_text(0)
	
	var compiled_group=GDScript.new()
	compiled_group.source_code=script_contents
	
	var path_used="res://FACS/Compiled/%s.gd"%group_name
	
	if FileAccess.file_exists(path_used):DirAccess.remove_absolute(ProjectSettings.globalize_path(path_used))
	
	ResourceSaver.save(compiled_group,path_used)
	
	#force update the editor for them
	#var script_editor=EditorInterface.get_script_editor()
	EditorInterface.get_resource_filesystem().update_file(path_used)

static func check_for(node):
	if node is ItemList:return node
	for child in node.get_children(true):
		var val=check_for(child)
		if val:return val
	
