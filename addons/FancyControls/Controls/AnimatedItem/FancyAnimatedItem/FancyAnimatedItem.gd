@tool
extends AnimatedItem
class_name FancyAnimatedItem
## Fancy version of [AnimatedItem]. Uses arrays and specified times and (optionally) tween type for each value to move towards


var target_chains:Dictionary={
	"position":[],
	"rotation":[],
	"scale":[]
}

enum AnimatableTypes{
	POSITION,
	ROTATION,
	SCALE
}

##fills the duty of syncing all action chains
func sync_chains()->void:
	chain_action(0,Vector2.ZERO,0,-9)
	chain_action(1,0.0,0,-9)
	chain_action(2,Vector2.ZERO,0,-9)

##utterly rediculous how this works.
##not that it's bad just could be better.
func chain_action(on_type:AnimatableTypes,target:Variant,duration:float=-1,tween_type:Tween.TransitionType=Tween.TRANS_LINEAR,relative:bool=false)->void:
	match on_type:
		AnimatableTypes.POSITION:
			assert(target is Vector2)
			target_chains.position.push_back({
				"goal":target,
				"duration":duration,
				"tween":tween_type,
				"relative":relative
			})
			if _tween_position==null||not _tween_position.is_valid():_target_chains_updated("position")
			
		AnimatableTypes.ROTATION:
			assert(target is float or target is int)
			target=float(target)
			target_chains.rotation.push_back({
				"goal":target,
				"duration":duration,
				"tween":tween_type
			})
			if _tween_rotation==null||not _tween_position.is_valid():_target_chains_updated("rotation")
			
		AnimatableTypes.SCALE:
			assert(target is Vector2)
			target_chains.scale.push_back({
				"goal":target,
				"duration":duration,
				"tween":tween_type
			})
			if _tween_scale==null||not _tween_position.is_valid():_target_chains_updated("scale")






##handles running the chain when it is added
func _target_chains_updated(updated_set:String)->void:
	#if Engine.is_editor_hint():return
	match updated_set:
		"position":
			var front_index=target_chains["position"].pop_front()
			if front_index==null:return
			#represents syncing
			if front_index.tween==-9:
				await tweens_synced
				_target_chains_updated("position")
				return
			
			_pos_trans=front_index.tween
			_pos_travel_time=front_index.duration
			_pos_relative=front_index.relative
			targeted_position=front_index.goal
			#so if the animator isnt creating a tween it just 
			if _tween_position!=null:_tween_position.finished.connect(_target_chains_updated.bind("position"))
			else:_target_chains_updated("position")
		"rotation":
			var front_index=target_chains["rotation"].pop_front()
			if front_index==null:return
			#represents syncing
			if front_index.tween==-9:
				await tweens_synced
				_target_chains_updated("rotation")
				return
			_rot_trans=front_index.tween
			_rot_travel_time=front_index.duration
			targeted_rotation=front_index.goal
			await get_tree().process_frame
			#i actually dont remember what this comment was for, i was sleep deprived making this work.
			#so if the animator isnt creating a tween it just 
			if _tween_rotation!=null:
				#_tween_rotation.set_trans(front_index.tween)
				_tween_rotation.finished.connect(_target_chains_updated.bind("rotation"))
			else:
				_target_chains_updated("rotation")
		"scale":
			var front_index=target_chains["scale"].pop_front()
			if front_index==null:return
			#represents syncing
			if front_index.tween==-9:
				await tweens_synced
				_target_chains_updated("scale")
				return

			_scale_trans=front_index.tween
			_scale_travel_time=front_index.duration
			targeted_scale=front_index.goal
			await get_tree().process_frame
			#so if the animator isnt creating a tween it just 
			if _tween_scale!=null:
				#_tween_scale.set_trans(front_index.tween)
				_tween_scale.finished.connect(_target_chains_updated.bind("scale"))
			else:_target_chains_updated("scale")





#region editor help and misc for managing it outside/inside the game
#an absolute mess
#do not touch this please it is very sensitive and will cry.

func _set(property, value):
	if property.contains("count"):
		target_chains[property.trim_suffix("_count")].resize(value)
		var null_count=target_chains[property.trim_suffix("_count")].count(null)
		while target_chains[property.trim_suffix("_count")].find(null)>-1:
			var nulls=target_chains[property.trim_suffix("_count")].find(null)
			match property:
				"position_count":
					target_chains[property.trim_suffix("_count")][nulls]={
						"goal":Vector2.ZERO,
						"duration":-1.0,
						"tween":Tween.TRANS_LINEAR
						}
				"scale_count":
					target_chains[property.trim_suffix("_count")][nulls]={
						"goal":Vector2.ONE,
						"duration":-1.0,
						"tween":Tween.TRANS_LINEAR
					}
				"rotation_count":
					target_chains[property.trim_suffix("_count")][nulls]={
						"goal":0.0,
						"duration":-1.0,
						"tween":Tween.TRANS_LINEAR
					}
		notify_property_list_changed()
	if property.contains("/") and (property.contains("position_") or property.contains("rotation_") or property.contains("scale_")):
		
		var type=property.split("_")[0]
		var number=int(property.trim_prefix(type+"_").split("/")[0])
		target_chains[type][number][property.split("/")[1]]=value
		notify_property_list_changed()



func _get(property):
	if property.contains("count"):
		return target_chains[property.trim_suffix("_count")].size()
	
	if property.contains("targets"):
		return target_chains[property.trim_suffix("_targets")]
	if property.contains("/") and (property.contains("position_") or property.contains("rotation_") or property.contains("scale_")):
		var type=property.split("_")[0]
		var number=int(property.trim_prefix(type+"_").split("/")[0])
		return target_chains[type][number][property.split("/")[1]]



func _get_property_list():
	var result:Array=[]
	_add_target_chain_property_to_list(TYPE_VECTOR2,"position",result)
	_add_target_chain_property_to_list(TYPE_FLOAT,"rotation",result)
	_add_target_chain_property_to_list(TYPE_VECTOR2,"scale",result)
	return result


func _add_target_chain_property_to_list(property_value_type:int,property_name:String,result:Array):
	result.append({
		&"name": "%s_count" % property_name,
		&"type": TYPE_INT,
		&"usage": PROPERTY_USAGE_DEFAULT | PROPERTY_USAGE_ARRAY,
		&"hint": PROPERTY_HINT_NONE,
		&"hint_string": "",
		&"class_name": "%s,%s_"% [property_name,property_name],
	})
	for i in target_chains[property_name].size():
		result.append({
			&"name": "%s_%s/goal" % [property_name,i],
			&"type": property_value_type,
		})
		result.append({
			&"name": "%s_%s/duration" % [property_name,i],
			&"type": TYPE_FLOAT,
		})
		result.append({
			&"name": "%s_%s/tween" % [property_name,i],
			&"type": TYPE_INT,
			&"hint": PROPERTY_HINT_ENUM,
			&"hint_string":",".join(ClassDB.class_get_enum_constants("Tween","TransitionType"))
		})
	return result
#endregion



