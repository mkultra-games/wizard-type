class_name HudScore
extends Label

var score := 0


func _on_en_destroyed(_enemy: Enemy) -> void:
	score += 1
	text = "Score: %s" % score
