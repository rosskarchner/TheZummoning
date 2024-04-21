extends StaticBody2D

var drag_event_started=false
@onready var raycast = get_parent().get_node("RayCast2D")

signal ingredient_added

func drop_available():
	return not raycast.is_colliding()


	
func _process(_delta):
	if Dragging.is_dragging and is_in_group("dropable") and drop_available():
		if not drag_event_started:
			$Sprite2D.modulate = Color(Color.MEDIUM_PURPLE)
			$Label.show()
		drag_event_started = true
		
	else:
		drag_event_started = false
		$Sprite2D.modulate = Color(Color.WHITE)
		$Label.hide()

func card_dropped(card):
	remove_from_group("dropable")
	card.reparent(self)
	ingredient_added.emit(card)
	
func update_label(text):
	$Label.text = text
