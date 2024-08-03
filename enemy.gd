class_name Enemy
extends RigidBody2D

signal destroyed(enemy: Enemy)

var search := false
var selected := false
var dead := false
var current_letter_idx := 0
var prompt := ""

@onready var label: RichTextLabel = $RichTextLabel
@onready var select_target: AnimatedSprite2D = $SelectTarget
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
	set_prompt()
	var enemy_types := sprite.sprite_frames.get_animation_names()
	sprite.play(enemy_types[randi() % enemy_types.size()])
	select_target.hide()


func set_prompt() -> void:
	prompt = "KILL"
	label.text = "[center]%s[/center]" % prompt


func select() -> void:
	selected = true
	select_target.show()
	select_target.play("selected")


func selectable() -> void:
	search = true
	if !selected:
		select_target.show()
		select_target.play("visible")


func deselect() -> void:
	if selected:
		select_target.hide()
	selected = false


func not_selectable() -> void:
	search = false
	if !selected:
		select_target.hide()


func receive_key(event: InputEventKey) -> void:
	# If the user double-tapped on the same frame, we might already be dead
	if dead:
		return

	# This is the magic ritual to get the human-readable equivalent of the key press, per
	# InputEventKey's documentation
	var keycode := DisplayServer.keyboard_get_keycode_from_physical(event.physical_keycode)
	var letter := OS.get_keycode_string(keycode)

	if prompt[current_letter_idx] == letter:
		current_letter_idx += 1
		var complete := prompt.substr(0, current_letter_idx)
		var incomplete := prompt.substr(current_letter_idx)
		label.text = "[center][color=green]%s[/color]%s[/center]" % [complete, incomplete]

	if current_letter_idx >= prompt.length():
		destroy()


func destroy() -> void:
	dead = true
	const WAVE := "amp=50.0 freq=5.0 connected=1"
	const RAINBOW := "freq=1.0 sat=0.8 val=0.8"
	label.text = (
		"[center][wave %s][rainbow %s]%s[/rainbow][/wave][/center]" % [WAVE, RAINBOW, prompt]
	)
	await get_tree().create_timer(0.25).timeout
	destroyed.emit(self)
	queue_free()
