extends CharacterBody2D

@onready var nav_agent := $NavigationAgent2D as NavigationAgent2D
@export var speed = 150
@export var laser: PackedScene
@export var ranged_unit = false
var max_speed = 150
var attack_range = 70

var target_radius = 10
var av = Vector2.ZERO
var avoid_weight = 0.1

var job_attack = false
var job_attack_unit = false
var target_id = null
var target_middle_of_enemy = null

var able_to_shoot = true
var new_id

var health = 10

var selected = false:
	set = set_selected
var target = null:
	set = set_target

func set_selected(value):
	selected = value
	if selected == true:
		$Body/backSprite.visible = true
		Global.units_selected = true
	else:
		$Body/backSprite.visible = false
		Global.units_selected = false

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
	Global.friendly_units += 1
	Global.population_count += 1
	
	var characters = 'abcdefghijklmnopqrstuvwxyz'
	new_id = Global.generate_id(characters, 10)
	add_to_group("unit")
	
	if ranged_unit == true:
		max_speed = 75
		attack_range = 150

func _physics_process(delta):
	makepath()
	move_towards_target()
	
	if selected == true and Global.new_worker_target != null:
		turn_off_all_jobs()
		target = Global.new_worker_target
		#refactor below
		if Global.new_worker_target_job == "attack_unit":
			job_attack_unit = true
			job_attack = true
			target_id = Global.new_worker_target_id
		if Global.new_worker_target_job == "attack_building":
			job_attack_unit = false
			job_attack = true
			target_id = Global.new_worker_target_id
		if Global.new_worker_target_type == "tile":
			find_closest_side_of_tile()
		#selected = false

	if velocity != Vector2(0, 0):
		$Body.look_at($NavigationAgent2D.get_next_path_position())

	if job_attack == true and target != null:
		var distance_to_enemy = (target - global_position).length()
		if distance_to_enemy <= attack_range:
			$Body.look_at(target_middle_of_enemy)
			speed = 0
			if able_to_shoot == true:
				able_to_shoot = false
				$TimerAttack.start()
				var new_laser = laser.instantiate()
				new_laser.is_good_laser = true
				add_sibling(new_laser)
				new_laser.position = $Body.global_position
				new_laser.look_at(target_middle_of_enemy)
				new_laser.owners_id = new_id
			var all_enemies = get_tree().get_nodes_in_group("enemy")
			var found_targeted_enemy = false
			for enemy in all_enemies:
				if enemy.new_id == target_id:
					target = enemy.position
					target_middle_of_enemy = target
					if job_attack_unit == false:
						find_closest_side_of_tile()
					found_targeted_enemy = true
			if found_targeted_enemy == false:
				job_attack = false
				target = null
				target_id = null
				turn_off_all_jobs()
		else:
			var all_enemies = get_tree().get_nodes_in_group("enemy")
			var found_targeted_enemy = false
			for enemy in all_enemies:
				if enemy.new_id == target_id:
					target = enemy.position
					target_middle_of_enemy = target
					if job_attack_unit == false:
						find_closest_side_of_tile()
					found_targeted_enemy = true
			if found_targeted_enemy == false:
				job_attack = false
				target = null
				target_id = null
				turn_off_all_jobs()
			speed = max_speed
	if job_attack == false and target == null:
		var all_units = get_tree().get_nodes_in_group('enemy')
		for unit in all_units:
			var distance_to_unit = (unit.position - global_position).length()
			if distance_to_unit <= 150 and target_id == null:
				target_id = unit.new_id
				job_attack = true
				if unit.is_a_building == true:
					job_attack_unit = false
				target_middle_of_enemy = unit.position
				target = unit.position
	$ProgressBar.value = health
	if health <= 0:
		Global.enemy_units -= 1
		Global.population_count -= 1
		queue_free()

func find_closest_side_of_tile():
	if target != null and target.x < self.position.x and target.y < self.position.y:
		target.x = target.x + 40
		target.y = target.y + 40
	if target != null and target.x < self.position.x and target.y > self.position.y:
		target.x = target.x + 40
		target.y = target.y - 40
	if target != null and target.x > self.position.x and target.y < self.position.y:
		target.x = target.x - 40
		target.y = target.y + 40
	if target != null and target.x > self.position.x and target.y > self.position.y:
		target.x = target.x - 40
		target.y = target.y - 40

func _on_area_2d_area_entered(area):
	if area.is_in_group("enemy_laser"):
		health -= 1
		if target_id != area.owners_id:
			turn_off_all_jobs()
			job_attack = true
			job_attack_unit = true
			target_id = area.owners_id
			$Body.look_at(area.position)
			var all_enemies = get_tree().get_nodes_in_group("enemy")
			for enemy in all_enemies:
				if enemy.new_id == target_id:
					target = enemy.position
					target_middle_of_enemy = target
		area.queue_free()

func turn_off_all_jobs():
	target_id = null
	job_attack = false
	job_attack_unit = false
	speed = max_speed

func _on_timer_attack_timeout():
	able_to_shoot = true
