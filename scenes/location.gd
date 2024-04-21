extends Node2D

@onready var enemy_space_full_detector=$EnemySpaceFullDetector

func can_take_new_enemy():
	enemy_space_full_detector.force_raycast_update()
	var result= not  enemy_space_full_detector.is_colliding()
	return result

func advance_creatures():
	var friendly_creatures = []
	var adversary_creatures = []
	for child in get_children():
		if child.is_in_group("creatures") and child.is_in_group("friendly"):
			friendly_creatures.append(child)
		elif child.is_in_group("creatures") and child.is_in_group("adversary"):
			adversary_creatures.append(child)

	for i in range(5):
		if friendly_creatures.size() >= i+1:
			if is_instance_valid(friendly_creatures[i]):
				friendly_creatures[i].advance_or_attack()
				await get_tree().create_timer(0.5).timeout
		if adversary_creatures.size() >= i+1: 
			if is_instance_valid(adversary_creatures[i]):
				adversary_creatures[i].advance_or_attack()
				await get_tree().create_timer(0.5).timeout
