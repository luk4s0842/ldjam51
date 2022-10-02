extends KinematicBody2D

func _ready():
	position = Utils.snapped_position(position)
	Events.emit_signal('register_box', position)


func _on_Area2D_body_entered(body:Node):
	if body.name == 'Player':
		Events.emit_signal('game_over')
