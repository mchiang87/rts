extends Node2D
#todo update costs and make into constants

@export var new_town_center: PackedScene
@export var house: PackedScene
@export var farm: PackedScene
@export var barracks: PackedScene
@export var range_building: PackedScene
@export var tower: PackedScene

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
		
