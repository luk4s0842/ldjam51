extends Node2D

signal start_timer
signal loaded_level

onready var animation_player = $AnimationPlayer
onready var grid = $Grid
onready var level_label = $CanvasLayer/LevelLabel

var moving_boxes_count = 0
var moving_boxes_stopped = 0
var box_positions = []
var current_level = 1
var current_level_instance
var level_finished = false
var is_game_over = false

func _ready():
	Events.connect('register_box', self, '_on_register_box')
	Events.connect('remove_box', self, '_on_remove_box')
	Events.connect('show_grid', self, '_on_show_grid')
	Events.connect('hide_grid', self, '_on_hide_grid')
	Events.connect('moving_box_stopped', self, '_on_moving_box_stopped')


func load_level(level_nr):
	if is_instance_valid(current_level_instance):
		current_level_instance.queue_free()

	yield(get_tree(), "idle_frame")

	reset_level_data()
	current_level = level_nr
	level_label.text = "Level %s" % level_nr
	var level = load('res://levels/Level%s.tscn' % level_nr).instance()
	level.connect('loaded_level', self, '_on_loaded_level')

	add_child(level)
	current_level_instance = level
	for child in level.get_children():
		if child.has_method('stand'):
			moving_boxes_count += 1
	level_finished = false
	is_game_over = false


func reload_current_level():
	load_level(current_level)

func _on_loaded_level():
	emit_signal('loaded_level')


func on_rotate_done():
	if not is_instance_valid(current_level_instance):
		return

	moving_boxes_stopped = 0
	for child in current_level_instance.get_children():
		if child.has_method('activate'):
			child.activate()

func on_rotate():
	if not is_instance_valid(current_level_instance):
		return

	for child in current_level_instance.get_children():
		if child.has_method('deactivate'):
			child.deactivate()


func _on_register_box(pos):
	box_positions.append(pos)

func _on_remove_box(pos):
	var b = box_positions.find(pos)
	if b != -1:
		box_positions.remove(b)

func is_free(pos):
	return !box_positions.has(pos)

func _on_show_grid():
	grid.show()
	animation_player.play('show_grid')

func _on_hide_grid():
	animation_player.play('hide_grid')


func _on_AnimationPlayer_animation_finished(anim_name:String):
	if anim_name == 'hide_grid':
		grid.hide()


func _on_moving_box_stopped():
	if level_finished or is_game_over:
		return

	moving_boxes_stopped += 1
	if moving_boxes_stopped >= moving_boxes_count:
		if not is_instance_valid(current_level_instance):
			return

		emit_signal('start_timer')

		for child in current_level_instance.get_children():
			if child.has_method('make_movable'):
				child.make_movable()

func game_over():
	reset_level_data()
	is_game_over = true
	if not is_instance_valid(current_level_instance):
		return

	current_level_instance.queue_free()


func reset_level_data():
	moving_boxes_count = 0
	moving_boxes_stopped = 0
	box_positions = []
