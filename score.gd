class_name HudScore
extends Label

var score := 0


# Called when the node enters the scene tree for the first time.
func _on_en_destroyed() -> void:
	score += 1
	text = "Score: %s" % score
