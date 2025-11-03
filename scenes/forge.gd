extends Node2D

signal card_played

enum Phase {CLOSED, OPEN_FOR_CREATURE, OPEN_FOR_ENHANCEMENT, FULL}


@export var direction:int

var current_phase:Phase = Phase.CLOSED:
	set(new_phase):
		current_phase = new_phase
		update_dropable()
		
var creature_details
var enhancement_details
var cards_played_here = []
var accepting_cards = false

@onready var creature_scene=preload("res://scenes/friendly_creature.tscn")

func _ready():

	add_to_group("player_forges")

	$CreatureDropBody.ingredient_added.connect(creature_added)
	$EnhancementDropBody.ingredient_added.connect(enhancement_added)

func enhancement_added(card):
	cards_played_here.append(card)
	enhancement_details = card.card_details
	current_phase = Phase.FULL
	card_played.emit()

func creature_added(card):
	cards_played_here.append(card)
	creature_details = card.card_details
	current_phase=Phase.OPEN_FOR_ENHANCEMENT
	card_played.emit()

func reset():
	current_phase = Phase.CLOSED

func close():
	$CreatureDropBody.remove_from_group("dropable")
	$CreatureDropBody.reset_appearance()
	$EnhancementDropBody.remove_from_group("dropable")
	$EnhancementDropBody.reset_appearance()

func open():
	$CreatureDropBody.add_to_group("dropable")
	#$CardDropBody2.add_to_group("dropable")

func update_dropable():
	match current_phase:
		Phase.CLOSED:
			$CreatureDropBody.remove_from_group("dropable")
			$CreatureDropBody.reset_appearance()
			$EnhancementDropBody.remove_from_group("dropable")
			$EnhancementDropBody.reset_appearance()
		Phase.OPEN_FOR_CREATURE:
			$CreatureDropBody.update_label("create")
			$CreatureDropBody.add_to_group("dropable")
			$EnhancementDropBody.remove_from_group("dropable")
			$EnhancementDropBody.reset_appearance()
		Phase.OPEN_FOR_ENHANCEMENT:
			$EnhancementDropBody.update_label("boost")
			$EnhancementDropBody.add_to_group("dropable")
			$CreatureDropBody.reset_appearance()

func summon():
	var parent = get_parent()
	for card in cards_played_here:
		card.queue_free.call_deferred()
	cards_played_here = []
	if not creature_details:
		return

	
	
	if creature_details:
		var new_creature = creature_scene.instantiate()
		new_creature.position= parent.get_node("Position1").position

		new_creature.populate(creature_details,enhancement_details)
		new_creature.add_to_group("creatures")
		parent.add_child(new_creature)
		
		
	creature_details=null
	enhancement_details = null
