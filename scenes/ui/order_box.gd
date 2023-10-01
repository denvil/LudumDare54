extends Control

func set_boxtype(type):
	if type == 0:
		$BoxA.visible = true
	elif type == 1:
		$BoxB.visible = true
	else:
		$BoxC.visible = true

func fade_out():
	var tween = create_tween()
	pivot_offset = size / 2
	tween.tween_property(self, "scale", Vector2(0,0), 0.3)
	tween.tween_callback(queue_free)
