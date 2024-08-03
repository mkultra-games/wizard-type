extends Node2D

@export var enemy_scene: PackedScene

var active_enemy_list: Array[Enemy] = []
var active_enemy: Enemy = null
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


func select_enemy(enemy: Enemy) -> void:
	get_tree().call_group("enemies", "deselect")
	active_enemy = enemy
	active_enemy.select()


# TODO: missing feature (picking enemy by first letter?)
#func find_new_active_enemy(typed_character: String) -> void:
#var enemy := $Enemy as Enemy
#var prompt := enemy.get_prompt()
#if prompt.substr(0, 1) == typed_character:
#active_enemy = enemy
#active_enemy.select()
#current_letter_index = 1
#active_enemy.set_text_completion(prompt, current_letter_index)


func _ready() -> void:
	new_game()


func _on_enemy_destroyed(enemy: Enemy) -> void:
	active_enemy_list.erase(enemy)
	oldest_enemy_active()


func oldest_enemy_active() -> void:
	select_enemy(active_enemy_list[0])


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

	err = en.destroyed.connect(_on_enemy_destroyed.bind())
	if err:
		printerr("failed to bind signal: %s" % err)

	active_enemy_list.push_back(en)
	if active_enemy == null:
		oldest_enemy_active()


func _unhandled_key_input(event: InputEvent) -> void:
	var key := event as InputEventKey
	if !key.pressed:
		return

	match key.keycode:
		KEY_ENTER:
			if hud_retry.visible:
				var err := get_tree().reload_current_scene()
				if err:
					printerr("failed to reload scene: %s" % err)
		KEY_TAB:
			selection_index = (selection_index + 1) % active_enemy_list.size()
			get_tree().call_group("enemies", "selectable")
			select_enemy(active_enemy_list[selection_index])
		_:
			if active_enemy == null:
				return

			selection_index = 0
			get_tree().call_group("enemies", "not_selectable")
			active_enemy.receive_key(key)


func _on_death_zone_hit() -> void:
	game_over()
