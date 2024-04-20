extends Node2D

signal card_played

enum ForgeOwner {PlayerForge, AdversaryForge}

@export var forge_owner:ForgeOwner=ForgeOwner.AdversaryForge
@export var direction:int

var ingredients = []
var cards_played_here = []
var accepting_cards = false

@onready var creature_scene=preload("res://scenes/friendly_creature.tscn")

func _ready():
	if forge_owner == ForgeOwner.AdversaryForge:
		$CardDropBody.remove_from_group("dropable")
		$CardDropBody2.remove_from_group("dropable")
		add_to_group("adversary_forges")
	else:
		add_to_group("player_forges")

	$CardDropBody.ingredient_added.connect(ingredient_added)
	$CardDropBody2.ingredient_added.connect(ingredient_added)

func ingredient_added(card):
	cards_played_here.append(card)
	ingredients.append(card.card_details)
	card_played.emit()

func close():
	$CardDropBody.remove_from_group("dropable")
	$CardDropBody2.remove_from_group("dropable")
	
func open():
	if forge_owner == ForgeOwner.PlayerForge:
		$CardDropBody.add_to_group("dropable")
		$CardDropBody2.add_to_group("dropable")

func summon():
	var parent = get_parent()
	for card in cards_played_here:
		card.queue_free.call_deferred()
		cards_played_here = []
	if not ingredients:
		return
	var bases = []
	var celestial_modifiers = []
	var base
	var celestial_modifier
	
	for ingredient in ingredients:
		if ingredient.House in ['plant', 'elements']:
			bases.append(ingredient)
		if ingredient.House == 'celestial':
			celestial_modifiers.append(ingredient)
	ingredients = []
	
	if bases and celestial_modifiers:
		base=bases[0]
		celestial_modifier = celestial_modifiers[0]
	elif bases:
		base = bases.pick_random()
		celestial_modifier = null
	
	if base:
		var new_creature = creature_scene.instantiate()
		new_creature.position= parent.get_node("Position1").position

		new_creature.populate(base,celestial_modifier)
		new_creature.add_to_group("creatures")
		parent.add_child(new_creature)
		
		
		
