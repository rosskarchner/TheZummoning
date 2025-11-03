extends Node

@onready var enemy_scene = preload("res://scenes/enemy_creature.tscn")


func place_enemy_at(location, creature_name=null):
	var enemy:= enemy_scene.instantiate()
	if creature_name:
		# Use specific creature type if provided
		if creature_name in Creature.creature_resources:
			enemy.description = Creature.creature_resources[creature_name]
			enemy.populate_from_description()
		else:
			enemy.random_creature()
	else:
		enemy.random_creature()
	enemy.position = location.get_node("Position5").position
	location.add_child(enemy)
	await get_tree().create_timer(0.5).timeout

func get_player_threat_assessment() -> Dictionary:
	"""Analyze player's board to determine threats and weaknesses"""
	var friendly_creatures = get_tree().get_nodes_in_group("friendly")
	var threat_levels = {
		"aggressive": 0,  # High strength creatures
		"defensive": 0,   # High defense creatures
		"count": friendly_creatures.size()
	}

	for creature in friendly_creatures:
		if creature.strength > creature.defense:
			threat_levels.aggressive += 1
		else:
			threat_levels.defensive += 1

	return threat_levels

func select_strategic_creature(threat_assessment: Dictionary) -> String:
	"""Select a creature type based on strategic needs"""
	var all_creatures = Creature.creature_resources.keys()
	var creature_stats = {}

	# Calculate stats for each creature type
	for creature_name in all_creatures:
		var resource = Creature.creature_resources[creature_name]
		creature_stats[creature_name] = {
			"strength": resource.base_strength,
			"defense": resource.base_defense,
			"hp": resource.base_hitpoints,
			"power": resource.base_strength + resource.base_defense + resource.base_hitpoints
		}

	# Strategy 1: If player has few creatures, go aggressive
	if threat_assessment.count < 2:
		# Select high strength creature
		var best_creature = null
		var best_strength = -1
		for name in creature_stats:
			if creature_stats[name].strength > best_strength:
				best_strength = creature_stats[name].strength
				best_creature = name
		return best_creature if best_creature else "xenomorph"

	# Strategy 2: If many aggressive enemies, go defensive
	if threat_assessment.aggressive > threat_assessment.defensive:
		# Select high defense creature
		var best_creature = null
		var best_defense = -1
		for name in creature_stats:
			if creature_stats[name].defense > best_defense:
				best_defense = creature_stats[name].defense
				best_creature = name
		return best_creature if best_creature else "martian"

	# Strategy 3: Default - pick balanced strong creature
	var best_creature = null
	var best_power = -1
	for name in creature_stats:
		if creature_stats[name].power > best_power:
			best_power = creature_stats[name].power
			best_creature = name
	return best_creature if best_creature else "xenomorph"

func place_enemies():
	var locations = get_tree().get_nodes_in_group("locations")
	var available_locations = locations.filter(func (l): return l.can_take_new_enemy())

	if not available_locations:
		get_parent().get_node("StateChart").send_event("adversary_choices_complete")
		return

	# Assess player's board state
	var threat_assessment = get_player_threat_assessment()

	# Select creatures strategically
	var first_creature = select_strategic_creature(threat_assessment)

	# Vary second creature selection slightly (might differ from first)
	var second_creature = first_creature
	if randf() > 0.6:  # 40% chance to pick a different creature type
		second_creature = select_strategic_creature(threat_assessment)

	# Place enemies in available locations
	var first = available_locations.pick_random()
	var second = available_locations.pick_random()

	place_enemy_at(first, first_creature)
	if not first == second: # if we picked the same location twice, only place 1
		place_enemy_at(second, second_creature)

	get_parent().get_node("StateChart").send_event("adversary_choices_complete")
