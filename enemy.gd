class_name Enemy
extends RigidBody2D

signal destroyed(enemy: Enemy)

var search := false
var selected := false
var dead := false

@onready var prompt: RichTextLabel = $AnimatedSprite2D/RichTextLabel
@onready var prompt_text := prompt.text
@onready var select_target: AnimatedSprite2D = $SelectTarget
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D


func _process(_delta: float) -> void:
	if search and !selected:
		select_target.show()
		select_target.play("visible")
	if selected:
		select_target.show()
		select_target.play("selected")
	if !selected and !search:
		select_target.hide()


func _ready() -> void:
	var enemy_types := sprite.sprite_frames.get_animation_names()
	sprite.play(enemy_types[randi() % enemy_types.size()])
	select_target.hide()


func get_prompt() -> String:
	var regex := RegEx.new()
	var _wontfail := regex.compile("\\[.*?\\]")
	var text_without_tags := regex.sub(prompt.text, "", true)
	return text_without_tags


func set_text_completion(sent_prompt: String, current_index: int) -> void:
	var complete := sent_prompt.substr(0, current_index)
	var incomplete := sent_prompt.substr(current_index)
	prompt.text = ("[center][color=green]%s[/color]%s[/center]" % [complete, incomplete])


func select() -> void:
	selected = true


func selectable() -> void:
	search = true


func deselect() -> void:
	selected = false


func not_selectable() -> void:
	search = false


func get_dead() -> bool:
	return dead


func destroy() -> void:
	dead = true
	const WAVE := "amp=50.0 freq=5.0 connected=1"
	const RAINBOW := "freq=1.0 sat=0.8 val=0.8"
	prompt.text = (
		"[center][wave %s][rainbow %s]%s[/rainbow][/wave][/center]" % [WAVE, RAINBOW, get_prompt()]
	)
	await get_tree().create_timer(0.25).timeout
	destroyed.emit(self)
	queue_free()
