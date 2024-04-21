extends Node

@onready var enemy_scene = preload("res://scenes/enemy_creature.tscn")


func place_enemy_at(location):
	var enemy:= enemy_scene.instantiate()
	enemy.random_creature()
	enemy.position = location.get_node("Position5").position
	location.add_child(enemy)
	await get_tree().create_timer(0.5).timeout

func place_enemies():
	var locations = get_tree().get_nodes_in_group("locations")
	var available_locations = locations.filter(func (l): return l.can_take_new_enemy())
	
	if not available_locations:
		get_parent().get_node("StateChart").send_event("adversary_choices_complete")
		return
	
	var first = available_locations.pick_random()
	var second = available_locations.pick_random()
	
	place_enemy_at(first)
	if not first == second: # if we picked the same location twice, only play 1
		place_enemy_at(second)
	
	get_parent().get_node("StateChart").send_event("adversary_choices_complete")
