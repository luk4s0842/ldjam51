extends Area2D

func _ready():
	$AnimationPlayer.play('animate')
	position = Utils.snapped_position(position)


func _on_GoalBox_body_entered(body:Node):
	if body.name == 'Player':
		Events.emit_signal('finished_level')
