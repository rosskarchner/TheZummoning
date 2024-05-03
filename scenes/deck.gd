extends Node2D

signal card_dealt

@onready var card_data = preload("res://data/cards.csv")
@onready var card_scene = preload("res://scenes/card.tscn")

func load_cards():
	var cards = []
	for card_details in card_data.records:
		for _i in range(0,int(card_details.Count)):
			var new_card=card_scene.instantiate()
			new_card.populate(card_details)
			cards.append(new_card)
	cards.shuffle()
	for card in cards:
		$Cards.add_child(card)

func _ready():
	load_cards()
	
func deal_next_card_to(hand:Node2D):
	var tween = get_tree().create_tween()
	if $Cards.get_child_count()< 1:
		load_cards()
	var next_card = $Cards.get_children()[-1]
	tween.tween_property(next_card, "global_position", hand.next_card_location, .5)
	next_card.revealed = true
	next_card.reparent(hand)
	next_card.add_to_group("playable")
	await tween.finished
	card_dealt.emit()

