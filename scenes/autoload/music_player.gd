extends AudioStreamPlayer



func _on_timer_timeout():
	play()


func _on_finished():
	$Timer.start()
