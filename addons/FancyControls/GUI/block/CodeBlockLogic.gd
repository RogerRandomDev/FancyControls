extends RefCounted
class_name CodeBlockLogic


static func FloatParameter(new_value,block,edit,param_id)->void:
	if not edit.visible:return
	if new_value is float:edit.value=new_value
	block.set_meta(&"value_%s"%str(param_id),new_value)

static func Vector2Parameter(new_value,block,edit,param_id,is_value_y)->void:
	if not edit.visible:return
	if new_value is Vector2:new_value=new_value.y if is_value_y else new_value.x
	if new_value is float:edit.value=new_value
	var link_val=block.get_meta(&"value_%s"%str(param_id),Vector2.ZERO)
	if link_val is String:return
	var new_vector = (
		Vector2(block.get_meta(&"value_%s"%str(param_id),Vector2.ZERO).x,new_value)
		if is_value_y else
		Vector2(new_value,block.get_meta(&"value_%s"%str(param_id),Vector2.ZERO).y)
	)
	block.set_meta(&"value_%s"%str(param_id),new_vector)
	edit.value=new_value

static func StringParameter(new_value,block,edit,param_id)->void:
	if not edit.visible:return
	if new_value is String:
		while new_value.begins_with("("):
			new_value=new_value.trim_prefix("(")
		edit.text=new_value
	block.set_meta(&"value_%s"%str(param_id),new_value)


static func PackedStringArrayParameter(new_value,block,edit,param_id,default_value)->void:
	if new_value is int:new_value=edit.get_item_text(new_value)
	block.set_meta(&"value_%s"%str(param_id),new_value)


static func BoolParameter(new_value,block,edit,param_id,default_value)->void:
	if not (new_value is bool):new_value=default_value
	block.set_meta(&"value_%s"%str(param_id),new_value)
