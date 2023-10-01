extends CanvasLayer

func set_score(score):
	%Score.text = str(score)
	
func set_rating(rating):
	%Rating.value = rating
	%RatingLabel.text = str(floor(rating*10))+" / 10"
	if rating < 0.2:
		%Rating.modulate = Color.ORANGE_RED
		



func _on_fail_debug_pressed():
	GameEvents.emit_failure()



