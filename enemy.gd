extends RigidBody2D

@onready var prompt = $AnimatedSprite2D/RichTextLabel
@onready var prompt_text = prompt.text

signal destroyed

var search = false
var selected = false
var dead = false

func _process(delta):
	if search and !selected:
		$SelectTarget.show()
		$SelectTarget.play("visible")
	if selected:
		$SelectTarget.show()
		$SelectTarget.play("selected")
	if !selected and !search:
		$SelectTarget.hide()

func _ready():
	var enemy_types = $AnimatedSprite2D.sprite_frames.get_animation_names()
	$AnimatedSprite2D.play(enemy_types[randi() % enemy_types.size()])
	$SelectTarget.hide()

func get_prompt():
	var regex = RegEx.new()
	regex.compile("\\[.*?\\]")
	var text_without_tags = regex.sub(prompt.text, "", true)
	return text_without_tags

func set_text_completion(sent_prompt: String, current_index):
	prompt.bbcode_text = "[center][color=green]" + sent_prompt.substr(0,current_index) + "[/color]" + sent_prompt.substr(current_index) + "[/center]"
	
func select():
	selected = true
	
func selectable():
	search = true
	
func deselect():
	selected = false
	
func not_selectable():
	search = false
	
func get_dead():
	return dead

func destroy():
	dead = true
	prompt.bbcode_text = "[center][wave amp=50.0 freq=5.0 connected=1][rainbow freq=1.0 sat=0.8 val=0.8]" + get_prompt() + "[/rainbow][/wave][/center]"
	await get_tree().create_timer(0.25).timeout
	destroyed.emit()
	queue_free()
