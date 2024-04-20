extends CharacterBody2D

@export var direction = -1
var creature_name:String:
	set(newName):
		creature_name = newName
		$NameLabel.text = description.name

var description:CreatureDescription
var hit_points_remaining:int
var hit_points_starting:int
var strength:int
var defense:int

var modifiers = []

const creature_resources = {
	"dryad": preload("res://data/creature_resources/dryad.tres"),
	"nymph":preload("res://data/creature_resources/nymph.tres"),
	"devil":preload("res://data/creature_resources/devil.tres"),
	"earth elemental": preload("res://data/creature_resources/earth_elemental.tres"),
	"flame elemental": preload("res://data/creature_resources/flame_elemental.tres"),
	"satyr":preload("res://data/creature_resources/satyr.tres")
}


@onready var raycast = $RayCast2D

func update_display():
	$StrengthLabel.text = str(strength)+"/"+str(defense)
	$HPLabel.text = "HP: " + str(hit_points_remaining)+"/"+str(hit_points_starting)
	if hit_points_remaining < hit_points_starting:
		$HPLabel.modulate = Color.RED
	else:
		$HPLabel.modulate = Color.DARK_GREEN

func modifier_math(current_value, operation, amount) -> int:
	if operation == "multiply":
		return current_value * amount
	else:
		return current_value + amount

func apply_modifiers():
	for modifier in modifiers:
		if modifier.attribute == "strength":
			strength = modifier_math(strength, modifier.operation, modifier.amount)
		elif modifier.attribute == "defense":
			defense = modifier_math(defense, modifier.operation, modifier.amount)
		elif modifier.attribute == "hitpoints":
			hit_points_starting=modifier_math(hit_points_starting, modifier.operation, modifier.amount)
			hit_points_remaining=hit_points_starting
	update_display()
			
func populate_from_description():
	creature_name = description.name
	strength = description.base_strength
	defense = description.base_defense
	hit_points_remaining=description.base_hitpoints
	hit_points_starting=description.base_hitpoints
	
	update_display()

func load_modifiers_from_card_data(card_data):
	
	for i in ["1","2"]:
		if card_data['ModifyAttribute'+i] != "":
			var modify_attribute
			if card_data['ModifyAttribute'+i] == "featured":
				match description.featured_attribute:
					CreatureDescription.Attrib.strength:
						modify_attribute="strength"
					CreatureDescription.Attrib.defense:
						modify_attribute="defense"
					CreatureDescription.Attrib.hitpoints:
						modify_attribute="hitpoints"
			elif card_data['ModifyAttribute'+i] == "featured_opposite":
				match description.featured_attribute:
					CreatureDescription.Attrib.strength:
						modify_attribute="defense"
					CreatureDescription.Attrib.defense:
						modify_attribute="hitpoints"
					CreatureDescription.Attrib.hitpoints:
						modify_attribute="strength"					
			else:
				modify_attribute = card_data['ModifyAttribute'+i]
			var modify_operation = card_data["ModifyOperation" + i]
			var modify_amount = float(card_data["ModifyAmount" + i])
			
			modifiers.append({
				"attribute": modify_attribute, 
				"operation": modify_operation,
				"amount" :modify_amount
			})
	

func populate(base, modifier=null):
	var resource_name=base.Creates.to_lower()
	description = creature_resources[resource_name]
	populate_from_description()
	
	if modifier:
		load_modifiers_from_card_data(modifier)
		apply_modifiers()
	if base and modifier:
		if base.Affinity == modifier.Name:
			creature_name = modifier["Affinity Name Modifier"].replace("%", base.Creates)
		else:
			creature_name = modifier["Name Modifier"].replace("%", base.Creates)
	else:
		creature_name = base.Creates

	$NameLabel.text = creature_name
	name=creature_name

func advance_or_attack():
	raycast.force_raycast_update()
	
	var my_group="friendly" if is_in_group("friendly") else "adversary"
	var opponent_group="adversary" if is_in_group("friendly") else "friendly"
	if raycast.is_colliding():
		var blocker = raycast.get_collider()
		if blocker.is_in_group(my_group):
			return # can't move or attack
		elif blocker.is_in_group(opponent_group):
			attack(blocker)
			raycast.force_raycast_update()
			if not raycast.is_colliding():
				advance()
	else:
		advance()
		
func advance():
	var tween= get_tree().create_tween()
	tween.tween_property(
		self,
	 	'position', 
		Vector2(position.x,position.y + (direction * 64)),
		.25
		)
	await tween.finished

func random_creature():
	description = creature_resources.values().pick_random()
	populate_from_description()

func attack(adversary):
	var effective_strength:float = float(strength) * (float(hit_points_remaining)/float(hit_points_starting))
	var differential = effective_strength - adversary.defense
	var damage = clamp(differential,1,100)
	adversary.take_damage(damage)
	#print(creature_name + " attacks " + adversary.creature_name)
	
func take_damage(amount):
	hit_points_remaining -= amount
	update_display()
	if hit_points_remaining < 1:
		queue_free()
	
