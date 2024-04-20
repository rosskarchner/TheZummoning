extends Node2D
var cards = []
var is_full = false

@onready var next_card_location:
	get:
		return Vector2(
			global_position.x + 90 * get_child_count(),
			global_position.y
		)


func reposition_cards():
	for i in range(len(cards)):
		var card = cards[i]
		card.position.x = i * 90



func _on_child_order_changed():
	cards=get_children()
	if get_child_count() >= 6:
		is_full=true
	else:
		is_full = false
	reposition_cards()
