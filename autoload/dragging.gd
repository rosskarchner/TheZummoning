extends Node2D

var is_dragging=false
var information_label
var timer

func update_infolabel(text):
	if not information_label:
		information_label = get_parent().get_node("Main").get_node("InformationLabel")
		timer = get_parent().get_node("Main").get_node("InfoLabelHideTimer")
	information_label.text=text
	information_label.show()
	timer.start()

