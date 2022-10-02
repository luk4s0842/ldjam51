extends Node2D

signal loaded_level

func _ready():
	randomize()
	$Box.hide()

	var children = get_children()
	children.shuffle()

	for child in children:
		if not child.name == 'Box':
			child.scale = Vector2.ZERO

	for child in children:
		if not child.name == 'Box':
			var tween = Tween.new()
			add_child(tween)
			tween.interpolate_property(child, 'scale', Vector2.ZERO, Vector2(1,1), 0.1)
			tween.start()
			yield(get_tree().create_timer(0.02), 'timeout')
		
	emit_signal('loaded_level')

