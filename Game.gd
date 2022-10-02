extends Node2D

const TIMER_DURATION = 10
const LEVELS_COUNT = 10

onready var tween = $Tween
onready var box = $Box
onready var rotate_timer = $RotateTimer
onready var progress_bar = $CanvasLayer/TextureProgress
onready var main_menu_popup = $CanvasLayer/MainMenu
onready var game_over_popup = $CanvasLayer/GameOver
onready var game_won_popup = $CanvasLayer/GameWon
onready var restart_level_button = $CanvasLayer/RestartButton

var current_rotation = 0
var rotating = false
var can_rotate = false

func _ready():
	Events.connect('game_over', self, '_on_game_over')
	Events.connect('finished_level', self, '_on_finished_level')
	box.connect('loaded_level', self, '_on_loaded_level')
	box.connect('start_timer', self, '_on_start_timer')
	main_menu_popup.show()

func _process(delta):
	progress_bar.value = rotate_timer.time_left

	if can_rotate and Input.is_action_just_pressed('ui_accept'):
		can_rotate = false
		rotate_timer.stop()
		_on_RotateTimer_timeout()



func rotate_box():
	var new_rotation = current_rotation + PI/2
	tween.interpolate_property(box, 'rotation', current_rotation, new_rotation, 1, Tween.TRANS_BACK)
	tween.start()
	rotating = true
	current_rotation = new_rotation
	
	

func _on_RotateTimer_timeout():
	can_rotate = false
	box.on_rotate()
	rotate_box()


func _on_Tween_tween_all_completed():
	rotating = false
	box.on_rotate_done()


func _on_start_timer():
	can_rotate = true
	rotate_timer.start()


func _on_game_over():
	if rotating:
		return
		
	can_rotate = false
	box.game_over()
	restart_level_button.hide()
	game_over_popup.show()
	reset_rotation()


func _on_GameOver_restart_game():
	game_over_popup.hide()
	restart_level_button.show()
	reset_rotation()
	box.reload_current_level()


func _on_MainMenu_start_game():
	main_menu_popup.hide()
	progress_bar.max_value = TIMER_DURATION
	progress_bar.value = TIMER_DURATION
	rotate_timer.wait_time = TIMER_DURATION
	restart_level_button.show()
	box.load_level(1)

func _on_loaded_level():
	start_game()

func start_game():
	can_rotate = true
	rotate_timer.start()


func _on_finished_level():
	if rotating:
		return

	box.level_finished = true
	can_rotate = false

	if box.current_level >= LEVELS_COUNT:
		box.game_over()
		game_won_popup.show()
		restart_level_button.hide()
	else:
		restart_level_button.show()
		reset_rotation()
		box.load_level(box.current_level+1)

func reset_rotation():
	box.rotation = 0
	current_rotation = 0


func _on_GameWon_play_again():
	game_won_popup.hide()
	reset_rotation()
	box.load_level(1)


func _on_RestartButton_pressed():
	tween.stop_all()
	reset_rotation()
	box.reload_current_level()
	rotate_timer.stop()
	progress_bar.value = TIMER_DURATION
