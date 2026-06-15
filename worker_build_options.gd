extends Node2D
#todo update costs and make into constants

@export var new_town_center: PackedScene
@export var house: PackedScene
@export var farm: PackedScene
@export var barracks: PackedScene
@export var range_building: PackedScene
@export var tower: PackedScene
@onready var build_option_info = $BuildOptionInfo
@onready var label_build_option_info = $BuildOptionInfo/LabelBuildOptionInfo


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_button_build_town_center_pressed():
	if Global.wood_count >= 50 and Global.gold_count >= 50:
		var new_building = new_town_center.instantiate()
		$"../../GameObjects".add_child(new_building)

func _on_button_build_house_pressed():
	if Global.wood_count >= 50:
		var new_building = house.instantiate()
		$"../../GameObjects".add_child(new_building)

func _on_button_build_barracks_pressed():
	if Global.wood_count >= 50:
		var new_building = barracks.instantiate()
		$"../../GameObjects".add_child(new_building)

func _on_button_build_range_pressed():
	if Global.wood_count >= 50:
		var new_building = range_building.instantiate()
		$"../../GameObjects".add_child(new_building)

func _on_button_build_tower_pressed():
	if Global.wood_count >= 50:
		var new_building = tower.instantiate()
		$"../../GameObjects".add_child(new_building)

func _on_button_build_farm_pressed():
	if Global.wood_count >= 50:
		var new_building = farm.instantiate()
		$"../../GameObjects".add_child(new_building)

func _on_button_build_town_center_mouse_entered():
	build_option_info.visible = true
	label_build_option_info.text = 'Build Town Center'

func _on_button_build_town_center_mouse_exited():
	build_option_info.visible = false

func _on_button_build_house_mouse_entered():
	build_option_info.visible = true
	label_build_option_info.text = 'Build House'

func _on_button_build_house_mouse_exited():
	build_option_info.visible = false

func _on_button_build_barracks_mouse_entered():
	build_option_info.visible = true
	label_build_option_info.text = 'Build Barracks'

func _on_button_build_barracks_mouse_exited():
	build_option_info.visible = false

func _on_button_build_range_mouse_entered():
	build_option_info.visible = true
	label_build_option_info.text = 'Build Ranged Training'

func _on_button_build_range_mouse_exited():
	build_option_info.visible = false

func _on_button_build_tower_mouse_entered():
	build_option_info.visible = true
	label_build_option_info.text = 'Build Defense Tower'

func _on_button_build_tower_mouse_exited():
	build_option_info.visible = false

func _on_button_build_farm_mouse_entered():
	build_option_info.visible = true
	label_build_option_info.text = 'Build Farm'

func _on_button_build_farm_mouse_exited():
	build_option_info.visible = false
