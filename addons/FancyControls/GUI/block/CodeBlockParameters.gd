@tool
extends Resource
class_name CodeBlockParameters

@export var ParameterName:String
@export var ParameterType:Variant.Type:
	set(v):
		ParameterType=v
		notify_property_list_changed()
@export var Editable:bool=true
@export_enum(
	"Left",
	"Right"
	) var PartOnSide=0

@export var specialDefault:String=""
@export var extra_resets:PackedInt32Array=PackedInt32Array([])
var DefaultValue


func _get_property_list():
	var result=[]
	var list_of_types:Array=[]
	for i in TYPE_MAX:
		list_of_types.push_back(type_string(i))
	
	result.append(
		{
			&"name": "DefaultValue",
			&"type": ParameterType,
			&"usage": PROPERTY_USAGE_DEFAULT
		}
	)
	return result


func get_parts_for_block(built_block:Control,val:int=-1,port_id:int=-1)->void:
	var component = HBoxContainer.new()
	var lbl = Label.new()
	lbl.text=ParameterName
	component.add_child(lbl)
	match ParameterType:
		TYPE_INT:
			pass
		TYPE_FLOAT:
			if Editable:
				var edit=SpinBox.new()
				edit.allow_greater=true
				edit.allow_lesser=true
				edit.step=0.01
				component.add_child(edit)
				built_block.set_meta(&"value_%s"%str(port_id),DefaultValue)
				edit.set_meta(&"reset_value",DefaultValue)
				edit.value_changed.connect(CodeBlockLogic.FloatParameter.bind(built_block,edit,port_id))
				edit.size_flags_horizontal=Control.SIZE_EXPAND_FILL
				BlockColoring.ChangePortType(built_block,port_id,PartOnSide,TYPE_FLOAT)
			
		TYPE_VECTOR2:
			BlockColoring.ChangePortType(built_block,port_id,
			PartOnSide,
			TYPE_VECTOR2
			)
			if Editable:
				for i in 2:
					var edit=SpinBox.new()
					edit.allow_greater=true
					edit.allow_lesser=true
					edit.step=0.01
					component.add_child(edit)
					edit.set_meta(&"reset_value",DefaultValue.x if i == 0 else DefaultValue.y)
					edit.value_changed.connect(CodeBlockLogic.Vector2Parameter.bind(built_block,edit,port_id,i==1))
					edit.size_flags_horizontal=Control.SIZE_EXPAND_FILL
				built_block.set_meta(&"value_%s"%str(port_id),DefaultValue)
		TYPE_STRING:
			var edit=LineEdit.new()
			component.add_child(edit)
			built_block.set_meta(&"value_%s"%str(port_id),DefaultValue)
			edit.size_flags_horizontal=Control.SIZE_EXPAND_FILL
			edit.text_changed.connect(CodeBlockLogic.StringParameter.bind(built_block,edit,port_id))
		TYPE_PACKED_STRING_ARRAY:
			var edit=OptionButton.new()
			for item in len(DefaultValue)-1:edit.add_item(DefaultValue[item])
			component.add_child(edit)
			built_block.set_meta(&"value_%s"%str(port_id),DefaultValue[0])
			edit.item_selected.connect(CodeBlockLogic.PackedStringArrayParameter.bind(built_block,edit,port_id,DefaultValue))
			edit.size_flags_horizontal=Control.SIZE_EXPAND_FILL
			
		TYPE_BOOL:
			var edit=CheckBox.new()
			component.add_child(edit)
			built_block.set_meta(&"value_%s"%str(port_id),DefaultValue)
			edit.toggled.connect(CodeBlockLogic.BoolParameter.bind(built_block,edit,port_id,DefaultValue))
			edit.size_flags_horizontal=Control.SIZE_EXPAND_FILL
	apply_format_to_block(built_block,val,port_id,component)

func apply_format_to_block(block:FACSGraphNode,val,port_id,component)->void:
	block.add_child(component)
	block.set_slot_enabled_left(port_id,PartOnSide==0)
	block.set_slot_enabled_right(port_id,PartOnSide==1)
	
	BlockColoring.ChangePortType(block,port_id,PartOnSide+1,ParameterType)
	
