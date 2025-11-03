class_name Creature
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
var is_dead:= false
var texture:AtlasTexture
var color:Color

var modifiers = []
var attack_animation_scene=preload("res://scenes/attack_animation.tscn")
var damage_placard_scene=preload("res://scenes/damage_placard.tscn")
var death_placard_scene=preload("res://scenes/death_placard.tscn")

const creature_resources = {
	"dryad": preload("res://data/creature_resources/dryad.tres"),
	"nymph":preload("res://data/creature_resources/nymph.tres"),
	"smoke_elemental":preload("res://data/creature_resources/smoke_elemental.tres"),
	"earth_elemental": preload("res://data/creature_resources/earth_elemental.tres"),
	"flame_elemental": preload("res://data/creature_resources/flame_elemental.tres"),
	"satyr":preload("res://data/creature_resources/satyr.tres"),
	"xenomorph": preload("res://data/creature_resources/xenomorph.tres"),
	"reptilian": preload("res://data/creature_resources/reptilian.tres"),
	"omicronian": preload("res://data/creature_resources/omicronian.tres"),
	"martian":preload("res://data/creature_resources/martian.tres"),
	"little_green_man": preload("res://data/creature_resources/little_green_men.tres"),
	"grays": preload("res://data/creature_resources/gray.tres")
}


@onready var raycast = $RayCast2D

func update_display():
	$StrengthLabel.text = str(strength)+"/"+str(defense)
	$HPLabel.text = "HP: " + str(hit_points_remaining)+"/"+str(hit_points_starting)
	if hit_points_remaining < hit_points_starting:
		$HPLabel.modulate = Color.RED
	else:
		$HPLabel.modulate = Color.DARK_GREEN
	if texture:
		$CreatureSprite.texture = texture
		if color:
			$CreatureSprite.modulate = color

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
	color = description.color
	texture = description.texture
	update_display()

func load_modifiers_from_card_data(card_data):
	
	for i in ["1"]:
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
	var resource_name=base.Creates.to_lower().replace(" ","_")
	if resource_name not in creature_resources:
		push_error("Creature not found: " + resource_name)
		return
	description = creature_resources[resource_name]
	populate_from_description()

	if modifier:
		load_modifiers_from_card_data(modifier)
		apply_modifiers()
	if base and modifier and "Name Modifier" in modifier:
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
			await attack(blocker)
			raycast.force_raycast_update()
			if not raycast.is_colliding():
				await advance()
	else:
		await advance()
		
func advance():
	var tween= get_tree().create_tween()
	tween.tween_property(
		self,
	 	'position', 
		Vector2(position.x,position.y + (direction * 64)),
		.25
		)
	return tween.finished

func random_creature():
	description = creature_resources.values().pick_random()
	populate_from_description()

func attack(adversary):
	if is_dead:
		return
	var effective_strength:float = float(strength) * (float(hit_points_remaining)/float(hit_points_starting))
	var differential = effective_strength - adversary.defense
	var damage = clamp(differential,1,100)
	var animation = attack_animation_scene.instantiate()
	if direction == 1:
		animation.rotation_degrees = 180
		animation.position.y = 28
		animation.position.x = -22
	else:
		animation.position.y = -28
		animation.position.x = 22
		
	add_child(animation)
	
	await adversary.take_damage(damage, self)
	#print(creature_name + " attacks " + adversary.creature_name)
	
func take_damage(amount, attacker):
	hit_points_remaining -= amount
	if hit_points_remaining < 1:
		is_dead=true
		var death_placard = death_placard_scene.instantiate()
		add_child(death_placard)
		await get_tree().create_timer(0.5).timeout
		attacker.advance()
		queue_free()
	var damage_placard = damage_placard_scene.instantiate()
	damage_placard.get_node("Label").text ="-" + str(int(amount))
	add_child(damage_placard)
	update_display()

	
