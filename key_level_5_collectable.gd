extends Area3D

signal collectedKey
func _on_body_entered(body):
	if body is Player:
		emit_signal("collectedKey")
		queue_free()
