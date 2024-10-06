extends Sprite2D


var goal_entered = false


func _on_goal_area_area_entered(area):
	if area.is_in_group("Ball"):
		goal_entered = true
		$GoalReached.play()

