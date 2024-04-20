extends Node2D

var cards_played_this_turn = 0:
	set(newval):
		cards_played_this_turn = newval
		configure_turn_ui()
		

@onready var player_forges = get_tree().get_nodes_in_group("player_forges")
@onready var post_game_message = preload("res://scenes/post_game_message.tscn")

func _ready():
	$EndTurnControls.hide()
	for forge in player_forges:
		forge.card_played.connect(func():cards_played_this_turn +=1)

func deal_some_cards(num=1):
	for i in range(num):
		await get_tree().create_timer(0.5).timeout
		print("dealing...")
		if not $PlayerHand.is_full:
			$Deck.deal_next_card_to($PlayerHand)
			print("dealt!")
		else:
			print("hand is full?")
		
func deal_next_card():
	deal_some_cards(2)


func _on_initial_deal_state_entered():
	deal_some_cards(2)




func _on_player_turn_state_entered():
	cards_played_this_turn = 0

func configure_turn_ui():
	if cards_played_this_turn <= 2:
		$EndTurnControls/EndTurnButton.disabled=false
	
	if cards_played_this_turn > 1:
		for forge in player_forges:
			forge.close()


func _on_end_turn_button_pressed():
	$StateChart.send_event("end_turn_clicked")


func _on_choices_state_exited():
	$EndTurnControls.hide()
	await get_tree().create_timer(0.5).timeout


func _on_act_on_choices_state_entered():
	get_tree().call_group("player_forges", "summon")


func _on_choices_state_entered():
	get_tree().call_group("player_forges", "open")
	$EndTurnControls.show()


func _on_advance_creatures_state_entered():
	get_tree().call_group("locations", "advance_creatures")
	$StateChart.send_event("complete")


func _on_player_lose_area_body_entered(body):
	var msg = post_game_message.instantiate()
	msg.get_node("%Message").text="Sorry, you've lost this match"
	msg.position = Vector2(1280/2, 720/2)
	add_child(msg)


func _on_player_win_area_body_entered(body):
	var msg = post_game_message.instantiate()
	msg.get_node("%Message").text="You've won this match!"
	msg.position = Vector2(1280/2, 720/2)
	add_child(msg)


func next_color():
	var colors = [
		Color.DARK_RED,
	 	Color.DARK_GREEN, 
		Color.DARK_BLUE, 
		Color.DARK_ORANGE, 
		Color.DARK_OLIVE_GREEN, 
		Color.DARK_MAGENTA]
	var tween = get_tree().create_tween()
	tween.tween_property($SpookyForest,"modulate", colors.pick_random(),15)
