extends Node2D
@onready var trail1 = $TrailPos/Trail
@onready var trail2 = $TrailPos2/Trail
@onready var trail3 = $TrailPos3/Trail


func start_fade():
	trail1.set_physics_process(false)
	trail2.set_physics_process(false)
	trail3.set_physics_process(false)
	
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(trail1, "modulate", Color.TRANSPARENT, 5)
	tween.tween_property(trail2, "modulate", Color.TRANSPARENT, 5)
	tween.tween_property(trail3, "modulate", Color.TRANSPARENT, 5)
	tween.set_parallel(false)
	tween.tween_callback(finished)
	
func finished():
	trail1.queue_free()
	trail2.queue_free()
	trail3.queue_free()
	queue_free()
