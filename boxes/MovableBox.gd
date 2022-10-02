extends KinematicBody2D

const GLOBAL_OFFSET = Vector2(512, 288)
const BORDER = 144

onready var animation_player = $AnimationPlayer

var hover = false
var moving = false
var active = true
var box

func _ready():
	box = get_node('/root/Game/Box')
	position = Utils.snapped_position(position)
	Events.emit_signal('register_box', position)


func _process(delta):
	if not active:
		stop_moving()
		return

	if hover and Input.is_action_just_pressed('left_click'):
		animation_player.play('hover')
		Events.emit_signal('show_grid')
		moving = true
	
	if Input.is_action_just_released('left_click'):
		stop_moving()

	if moving:
		var mouse_pos = get_global_mouse_position()
		mouse_pos.y -= 12
		var new_pos = Utils.snapped_position(mouse_pos) - GLOBAL_OFFSET
		new_pos = Vector2(clamp(new_pos.x, -BORDER, BORDER), clamp(new_pos.y, -BORDER, BORDER))
		new_pos = Utils.snapped_position(new_pos.rotated(-box.rotation))

		if is_free(new_pos):
			var pos_before = position
			position = new_pos

			if position != pos_before:
				Events.emit_signal('remove_box', pos_before)
				Events.emit_signal('register_box', position)


func is_free(pos):
	return box.is_free(pos)

func make_movable():
	active = true

func deactivate():
	active = false

func _on_MovableBox_mouse_exited():
	hover = false
	z_index = 1

func _on_MovableBox_mouse_entered():
	z_index = 2
	hover = true

func stop_moving():
	if moving:
		animation_player.play('end_hover')

	moving = false
	Events.emit_signal('hide_grid')

