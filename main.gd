extends Node2D

@export var enemy_scene: PackedScene

var active_enemy_list: Array[Enemy] = []
var active_enemy: Enemy = null
var current_letter_index := -1
var selection_index := 0

@onready var enemy_timer: Timer = $EnemyTimer
@onready var hud_retry: Control = $HUD/Retry
@onready var hud_score: HudScore = $HUD/Score
@onready var enemy_spawn: PathFollow2D = $EnemyPath/EnemySpawn


func new_game() -> void:
	enemy_timer.start()


func game_over() -> void:
	enemy_timer.stop()
	hud_retry.show()


func update_active_enemy_list() -> void:
	active_enemy_list.assign(get_tree().get_nodes_in_group("enemies"))


func select_mode_enemy_list() -> void:
	current_letter_index = -1
	get_tree().call_group("enemies", "selectable")
	select_enemy(active_enemy_list[selection_index])


func select_enemy(enemy: Enemy) -> void:
	get_tree().call_group("enemies", "deselect")
	active_enemy = enemy
	active_enemy.select()


func find_new_active_enemy(typed_character: String) -> void:
	var enemy := $Enemy as Enemy
	var prompt := enemy.get_prompt()
	if prompt.substr(0, 1) == typed_character:
		active_enemy = enemy
		active_enemy.select()
		current_letter_index = 1
		active_enemy.set_text_completion(prompt, current_letter_index)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	new_game()


func _on_enemy_timer_timeout() -> void:
	var en: Enemy = enemy_scene.instantiate()

	enemy_spawn.progress_ratio = randf()

	var direction := enemy_spawn.rotation + PI / 2
	en.position = enemy_spawn.position
	en.rotation = direction

	var velocity := Vector2(randf_range(100.0, 150.0), 0.0)
	en.linear_velocity = velocity.rotated(direction)

	add_child(en)
	var err := en.destroyed.connect(hud_score._on_en_destroyed.bind())
	if err:
		printerr("failed to bind signal: %s" % err)

	update_active_enemy_list()
	if active_enemy == null:
		if !active_enemy_list[0].get_dead():
			select_enemy(active_enemy_list[0])
		else:
			select_enemy(active_enemy_list[1])


func _unhandled_key_input(event: InputEvent) -> void:
	var key := event as InputEventKey
	if key.pressed:
		if key.as_text_key_label() == "Enter" and hud_retry.visible:
			var err := get_tree().reload_current_scene()
			if err:
				printerr("failed to reload scene: %s" % err)
		elif key.as_text_key_label() == "Tab":
			selection_index += 1
			select_mode_enemy_list()
		else:
			if active_enemy == null:
				update_active_enemy_list()
				if !active_enemy_list[0].get_dead():
					select_enemy(active_enemy_list[0])
				else:
					select_enemy(active_enemy_list[1])
			get_tree().call_group("enemies", "not_selectable")
			var prompt := active_enemy.get_prompt()
			if current_letter_index == -1:
				if prompt.substr(0, 1) == key.as_text_key_label():
					current_letter_index = 1
					active_enemy.set_text_completion(prompt, current_letter_index)
			else:
				var next_letter := prompt.substr(current_letter_index, 1)
				if key.as_text_key_label() == next_letter:
					current_letter_index += 1
					active_enemy.set_text_completion(prompt, current_letter_index)
				if prompt.length() <= current_letter_index:
					current_letter_index = -1
					active_enemy.destroy()
					active_enemy = null
					update_active_enemy_list()


func _on_death_zone_hit() -> void:
	game_over()
