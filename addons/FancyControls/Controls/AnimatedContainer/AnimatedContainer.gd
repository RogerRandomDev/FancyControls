@tool
extends Control
class_name AnimatedContainer

##updates the box contents whenever a child node is added
@export var auto_update:bool=true

@export var animate_spacing:bool=true

@export var border_padding:Vector2=Vector2.ZERO:
	set(v):
		border_padding=v
		_notification(NOTIFICATION_RESIZED)


func _ready():
	if not Engine.is_editor_hint():
		var is_auto=auto_update
		auto_update=false
		for child in get_children():
			child.position=Vector2.ZERO
			self.add_child(child,false)
		auto_update=is_auto
	_update_spacings.call_deferred(false)


func _update_spacings(animated:bool=true)->void:pass

func _editor_fit_contents()->void:pass



## overriding the default to allow some custom stuff to be handled.
## if set to an internal child, it will be stored normally and not as an item to hold
func add_child(child:Node,internal:bool=false,internal_mode:Node.InternalMode=Node.INTERNAL_MODE_DISABLED)->void:
	if child is AnimatedItem or Engine.is_editor_hint() or internal:
		super.add_child(child,internal,internal_mode)
		if Engine.is_editor_hint():
			_editor_fit_contents()
		
		return
	var child_holder=AnimatedItem.new(self,child)
	super.add_child(child_holder,internal,internal_mode)
	child_holder.owner=get_tree().get_edited_scene_root()











##basically just get_child()
func get_item(item_id:int=-1)->AnimatedItem:
	if item_id<0 or item_id>get_child_count()-1:return null
	return get_child(item_id)


func add_item(item:AnimatedItem)->void:
	add_child(item)

func add_item_from_position(item:AnimatedItem)->void:
	var start_position=item.global_position
	#creates new version of the item to clear the old one out and ignore any tweens on it
	item=AnimatedItem.new(self,item.attached_item)
	add_child(item)
	
	var ind=get_children().find(item)
	var child_position=get_target_position_for_item(ind)
	animate_item_from_position.call_deferred(item,start_position,child_position)



func animate_item_from_position(item:AnimatedItem,from_position:Vector2,to_position:Vector2)->void:
	item.global_position=from_position
	item.targeted_position=to_position


func get_target_position_for_item(id:int)->Vector2:return Vector2.ZERO







##used to handle some events that are emitted
func _notification(what):
	match what:
		NOTIFICATION_CHILD_ORDER_CHANGED:
			#fancy stuff going on here.
			#made with this so you can stop it if you dont want it
			if auto_update:
				if Engine.is_editor_hint():_editor_fit_contents()
				else:_update_spacings.call_deferred()
		NOTIFICATION_RESIZED:
			if auto_update:
				if Engine.is_editor_hint():_editor_fit_contents()
				else:_update_spacings.call_deferred()
