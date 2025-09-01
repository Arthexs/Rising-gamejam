extends BaseItem

func _ready() -> void:
	#super._ready()
	cost = 25
	text = "Gain  20%  Speed  (Cost:  25%)"

func effect() -> void:
	player.speed *= 1.2
	player.flash(Color.YELLOW, 0.5, 0.4)
	remove_self()
