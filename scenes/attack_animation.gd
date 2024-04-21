extends Node2D

func play_sound():
	var player = $AudioPlayers.get_children().pick_random()
	player.play()
