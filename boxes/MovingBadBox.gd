extends KinematicBody2D

const FALL_SPEED = 250
const STANDING_MARGIN = 1

var active = false
var move = Vector2.ZERO
var previous_pos
var direction = Vector2(0, 1)

func _ready():
	snap_to_grid()
	Events.emit_signal('register_box', position)

func _physics_process(_delta):
	if active:
		move = move_and_slide(direction * FALL_SPEED)
		
		if previous_pos and previous_pos.distance_to(position) <= STANDING_MARGIN:
			stand()

		previous_pos = position


func stand():
	active = false
	snap_to_grid()
	Events.emit_signal('moving_box_stopped')
	Events.emit_signal('register_box', position)

func activate():
	Events.emit_signal('remove_box', position)
	active = true

func snap_to_grid():
	position = Utils.snapped_position(position)


func _on_Area2D_body_entered(body:Node):
	if body.name == 'Player':
		Events.emit_signal('game_over')
