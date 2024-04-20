@tool
extends Node2D


func _draw():
	var outer_rect= Rect2(Vector2(-32,-32),Vector2(64,64))
	var inner_rect = Rect2(Vector2(-31,-31),Vector2(63,63))
	draw_rect(outer_rect,Color.BLACK)
	draw_rect(inner_rect, Color.WHITE)
