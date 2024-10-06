extends Node2D

@onready var goal = $Goal
@onready var swipe_ani = $SceneTransition/Ani
@onready var change_scene_timer = $ChangeSceneTimer

var timer_called = false

func _process(delta):
	if goal.goal_entered:
		if not timer_called:
			swipe_ani.play("SwipeDown")
			change_scene_timer.start()
			timer_called = true

func _on_change_scene_timer_timeout():
	get_tree().change_scene_to_file("res://Scenes/Levels/level_2.tscn")
