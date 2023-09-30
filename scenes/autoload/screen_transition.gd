extends CanvasLayer

signal transitioned_halfway
var skip_emit = false

func transition():
	$AnimationPlayer.play("default")
	await $AnimationPlayer.animation_finished
	transitioned_halfway.emit()
	$AnimationPlayer.play_backwards("default")
