@tool
class_name Card

extends Node2D

signal was_revealed

var draggable = false
var is_inside_dropable = false
var body_ref
var offset: Vector2
var initialPos: Vector2
var card_details: Dictionary

var celectial_label_settings = preload("res://resources/celestial_label_settings.tres")



@export var revealed=false:
	set(newval):
		revealed = newval
		handle_reveal()

func _ready():
	if revealed:
		$CardBack.hide()
		$CardDetails.show()
	else:
		$CardBack.show()
		$CardDetails.hide()	
	
	
func _draw():
	var outer_rect_size = Vector2(85, 128)
	var outer_rect_position = (outer_rect_size /2.0) * -1

	var outer_rect = Rect2(
		outer_rect_position,
		outer_rect_size
	)

	var inner_rect_size =  outer_rect_size - Vector2(2,2)
	var inner_rect_position = (inner_rect_size /2.0) * -1
	var inner_rect = Rect2(
		inner_rect_position,
		inner_rect_size
	)

	draw_rect(outer_rect, Color.BLACK)
	draw_rect(inner_rect, Color.WHITE)


func handle_reveal():
	if not is_node_ready():
		return
	if revealed:
		$AnimationPlayer.play("reveal")
		was_revealed.emit()
	else:
		$AnimationPlayer.play("hide")

func populate(dict):
	card_details = dict
	if card_details.House == "plant":
		%Leaf.show()
	elif card_details.House == "elements":
		%CarbonDioxide.show()
	elif card_details.House == "celestial":
		%CelestialCard.show()
		$CardDetails/Label.label_settings = celectial_label_settings

	$CardDetails/Label.text=dict.Name
	

func _process(_delta):
	if Engine.is_editor_hint():
		return
		
	if draggable and is_in_group("playable"):
		if Input.is_action_just_pressed("click"):
			offset = get_global_mouse_position() - global_position
			initialPos=global_position
			Dragging.is_dragging = true
			modulate.a = 0.5
		if Input.is_action_pressed("click"):
			
			global_position = get_global_mouse_position()
		elif Input.is_action_just_released("click"):
			modulate.a =1
			Dragging.is_dragging = false
			var tween = get_tree().create_tween()
			if is_inside_dropable and body_ref:
				tween.tween_property(self, "global_position", body_ref.global_position,0.2).set_ease(Tween.EASE_OUT)
				tween.tween_property(self, "scale",Vector2(0.5,0.5),0.2).set_ease(Tween.EASE_OUT)
				remove_from_group("playable")
				draggable=false
				body_ref.modulate = Color(Color.WHITE, 1)
				body_ref.card_dropped(self)
				$DragArea.monitoring=false
				body_ref = null

			else:
				tween.tween_property(self, "global_position", initialPos,0.2).set_ease(Tween.EASE_OUT)
			

		var global_rect_size = Vector2(85, 128)
		
		var outer_rect = Rect2(
			global_position - (Vector2(85, 128) /2.0),
			global_rect_size
		)
		
		var mouse_pos = get_global_mouse_position()
		
		if outer_rect.has_point(mouse_pos):
			Dragging.update_infolabel(card_description())

func _on_drag_area_body_entered(body):
	if body.is_in_group('dropable') and body.drop_available() and not body_ref:
		is_inside_dropable = true
		body.modulate = Color(Color.GOLDENROD, 1)
		body_ref = body


func _on_drag_area_body_exited(body):
	if body.is_in_group('dropable') and body.drop_available():
		is_inside_dropable = false
		body.modulate = Color(Color.MEDIUM_PURPLE)
		body_ref= null


func _on_click_area_mouse_entered():
	if is_in_group("playable") and not Dragging.is_dragging:
		draggable = true
		scale *= 1.1
		



func _on_click_area_mouse_exited():
	if is_in_group("playable") and not Dragging.is_dragging:
		draggable = false
		scale = Vector2(1.0,1.0)

func creature_description() -> CreatureDescription:
	var lookup_name = card_details.Creates.to_lower().replace(" ","_")
	return Creature.creature_resources[lookup_name]

func stats_string():
	var description:CreatureDescription = creature_description()
	var result = "Str:"+str(description.base_strength)
	result +=  "/Def:" + str(description.base_defense)
	result +=  "/HP:" + str(description.base_hitpoints)
	return result

func boost_string():
	var result=""
	if card_details.ModifyOperation1 == "add":
		result+="+"
	elif card_details.ModifyOperation1 == "multiply":
		result +="X"
	result += str(card_details.ModifyAmount1) + " "
	result += card_details.ModifyAttribute1
	return result

func card_description():
	var info_string = "Create a " + card_details.Creates
	info_string += "("+stats_string()+ ") "
	info_string+= "or boost another card with "+ boost_string()
	return info_string
