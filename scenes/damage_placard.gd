extends Node2D

var is_dead = false

@onready var death_placard_scene=preload("res://scenes/death_placard.tscn")

func queue_free_or_show_death():
	if is_dead:
		queue_free()
	else:
		$ColorRect.queue_free()
		$Label.queue_free()
		$AnimationPlayer.play("show_death")	
func queue_free_parent():
	get_parent().queue_free()
