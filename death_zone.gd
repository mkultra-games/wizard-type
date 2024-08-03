extends Area2D

signal hit


func _on_body_entered(_body: Node) -> void:
	hit.emit()
