extends Area2D

var is_good_laser = false
var owners_id

func _ready():
	if is_good_laser == true:
		add_to_group('unit_laser')
		$ColorRect.modulate = Color('#00ffff')
	else:
		add_to_group('enemy_laser')
		$ColorRect.modulate = Color('#ff0000')

func _process(delta):
	move_local_x(100 * delta)

func _on_timer_timeout():
	queue_free()
