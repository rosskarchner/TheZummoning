extends Node2D

var is_dragging=false
var information_label
var timer

func update_infolabel(text):
	if not information_label:
		var main = get_parent().get_node_or_null("Main")
		if main:
			information_label = main.get_node_or_null("InformationLabel")
			timer = main.get_node_or_null("InfoLabelHideTimer")
	if information_label:
		information_label.text=text
		information_label.show()
	if timer:
		timer.start()
