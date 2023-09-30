extends TextureRect

func fade_out():
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2(0,0), 0.3)
	tween.tween_callback(queue_free)
