extends Node2D

@export var enemy_scene: PackedScene

var active_enemy_list = []
var active_enemy = null
var current_letter_index = -1
var selection_index = 0

func new_game():
	$EnemyTimer.start()

func game_over():
	$EnemyTimer.stop()
	$HUD/Retry.show()
	

func update_active_enemy_list():
	active_enemy_list = get_tree().get_nodes_in_group("enemies")

func select_mode_enemy_list():
	current_letter_index = -1
	get_tree().call_group("enemies","selectable")
	select_enemy(active_enemy_list[selection_index])
	
func select_enemy(enemy):
	get_tree().call_group("enemies","deselect")
	active_enemy = enemy
	active_enemy.select()

func find_new_active_enemy(typed_character:String):
	var prompt = $Enemy.get_prompt()
	if prompt.substr(0,1)==typed_character:
		active_enemy = $Enemy
		active_enemy.select()
		current_letter_index = 1
		active_enemy.set_text_completion(prompt,current_letter_index)

# Called when the node enters the scene tree for the first time.
func _ready():
	new_game()

func _on_enemy_timer_timeout():
	var en = enemy_scene.instantiate()
	
	var en_spawn = $EnemyPath/EnemySpawn
	en_spawn.progress_ratio = randf()
	
	var direction = en_spawn.rotation + PI/2
	en.position = en_spawn.position
	en.rotation = direction
	
	var velocity = Vector2(randf_range(100.0,150.0),0.0)
	en.linear_velocity = velocity.rotated(direction)
	
	add_child(en)
	en.destroyed.connect($HUD/Score._on_en_destroyed.bind())
	update_active_enemy_list()
	if active_enemy == null:
		if !active_enemy_list[0].get_dead():
			select_enemy(active_enemy_list[0])
		else:
			select_enemy(active_enemy_list[1])
		

func _unhandled_key_input(event):
	if event.pressed:
		if event.as_text_key_label() == "Enter" and $HUD/Retry.visible:
			get_tree().reload_current_scene()
		elif event.as_text_key_label() == "Tab":
			selection_index += 1
			select_mode_enemy_list()
		else:
			if active_enemy == null:
				update_active_enemy_list()
				if !active_enemy_list[0].get_dead():
					select_enemy(active_enemy_list[0])
				else:
					select_enemy(active_enemy_list[1])
			get_tree().call_group("enemies","not_selectable")
			var prompt = active_enemy.get_prompt()
			if current_letter_index == -1:
				if prompt.substr(0,1)==event.as_text_key_label():
					current_letter_index = 1
					active_enemy.set_text_completion(prompt,current_letter_index)
			else:
				var next_letter = prompt.substr(current_letter_index,1)
				if event.as_text_key_label() == next_letter:
					current_letter_index += 1
					active_enemy.set_text_completion(prompt,current_letter_index)
				if prompt.length() <= current_letter_index:
					current_letter_index = -1
					active_enemy.destroy()
					active_enemy = null
					update_active_enemy_list()


func _on_death_zone_hit():
	game_over();
