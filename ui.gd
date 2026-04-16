extends CanvasLayer
#todo may refactor some redundant looking logic

@onready var label_wood = $ResourceText/LabelWood
@onready var label_food = $ResourceText/LabelFood
@onready var label_gold = $ResourceText/LabelGold
@onready var label_population = $ResourceText/LabelPopulation
@onready var worker_build_options = $workerBuildOptions
@onready var win_screen = $WinScreen
@onready var lose_screen = $LoseScreen

var game_is_on = false

func _ready():
	pass # Replace with function body.

func _process(delta):
	label_wood.text = "Wood: " + str(Global.wood_count)
	label_food.text = "Food: " + str(Global.food_count)
	label_gold.text = "Gold: " + str(Global.gold_count)
	label_population.text = "Population: " + str(Global.population_count) + " / " + str(Global.max_population_count)

	if Global.workers_selected == true:
		worker_build_options.visible = true
	if Global.workers_selected == false:
		worker_build_options.visible = false

	if Global.enemy_units == 0 and game_is_on == true:
		win_screen.visible = true
	if Global.friendly_units == 0 and game_is_on == true:
		lose_screen.visible = true

func _on_timer_game_on_timeout():
	game_is_on = true

func _on_button_play_again_pressed():
	Global.reset_all_var()
	get_tree().reload_current_scene()
