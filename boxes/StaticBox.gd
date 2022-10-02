extends StaticBody2D


func _ready():
	position = Utils.snapped_position(position)
	Events.emit_signal('register_box', position)
