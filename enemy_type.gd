extends CharacterBody2D

@onready var nav_agent := $NavigationAgent2D as NavigationAgent2D
@export var speed = 150
@export var laser: PackedScene

var target_id = null
var target_middle_enemy_building = null
var target_radius = 10
var av = Vector2.ZERO
var avoid_weight = 0.1

var attacking_unit = false
var able_to_shoot = true
var new_id

var health = 10

@export var is_ranged_unit = false
var attack_range = 70
var unit_speed = 150
var is_a_building = false

var target = null:
	set = set_target

func set_target(value):
	target = value

func avoid():
	var result = Vector2.ZERO
	var neighbors = $Area2D.get_overlapping_bodies()
	if neighbors:
		for neighbor in neighbors:
			result += neighbor.position.direction_to(position)
		result /= neighbors.size()
	return result.normalized()
	
func _on_navigation_agent_2d_veloctiy_computed(safe_velocity: Vector2) -> void:
	velocity = safe_velocity

func makepath():
	if target != null:
		nav_agent.target_position = target

func move_towards_target():
	velocity = Vector2.ZERO
	if target != null:
		velocity = position.direction_to(target)
		var dir = to_local(nav_agent.get_next_path_position()).normalized()
		velocity = dir * speed
		if position.distance_to(target) < target_radius:
			target = null
	av = avoid()
	velocity = (velocity + av * avoid_weight).normalized() * speed
	
	if nav_agent.avoidance_enabled:
		nav_agent.set_velocity(velocity)
	else:
		_on_navigation_agent_2d_veloctiy_computed(velocity)
	
	move_and_slide()
	var next_path_pos = nav_agent.get_next_path_position()

func _ready():
	Global.enemy_units += 1
	add_to_group('enemy')
	var characters = 'abcdefghijklmnopqrstuvwxyz'
	new_id = generate_id(characters, 10)
	if is_ranged_unit == true:
		attack_range = 150
		unit_speed = 75

func _process(delta):
	if health <= 0:
		Global.enemy_units -= 1
		queue_free()
	$ProgressBar.value = health
	
	var all_units = get_tree().get_nodes_in_group('unit')
	for unit in all_units:
		var distance_to_unit = (unit.position - global_position).length()
		if distance_to_unit <= 150 and target_id == null:
			target_id = unit.new_id
	if target_id != null:
		var unit_exists = false
		for unit in all_units:
			var distance_to_unit = (unit.position - global_position).length()
			if unit.new_id == target_id and distance_to_unit >= attack_range:
				target = unit.position
				makepath()
				move_towards_target()
				speed = unit_speed
			elif unit.new_id == target_id and distance_to_unit <= attack_range and able_to_shoot == true:
				able_to_shoot = false
				$TimerShoot.start()
				var new_laser = laser.instantiate()
				new_laser.is_good_laser = false
				add_sibling(new_laser)
				new_laser.position = $body.global_position
				new_laser.look_at(unit.position)
				new_laser.owners_id = new_id
				speed = 0
			if unit.new_id == target_id:
				$body.look_at(unit.position)
				unit_exists = true
		if unit_exists == false:
			target_id = null

func generate_id(chars, length):
	var word: String
	var n_char = len(chars)
	for i in range(length):
		word += chars[randi() % n_char]
	return word

func _on_timer_shoot_timeout():
	able_to_shoot = true

func _on_area_2d_area_entered(area):
	if area.is_in_group('unit_laser'):
		health -= 1
		attacking_unit = true
		target_id = area.owners_id
		$body.look_at(area.position)
		area.queue_free()

func _on_button_attack_me_pressed():
	if Global.workers_selected == true:
		Global.new_worker_target = position
		Global.new_worker_target_job = 'attack_unit'
		Global.new_worker_target_id = new_id
		$TimerRemoveNav.start()

func _on_timer_remove_nav_timeout():
	Global.new_worker_target = null
	Global.new_worker_target_job = null
	Global.new_worker_target_id = null
