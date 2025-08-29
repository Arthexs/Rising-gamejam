extends CanvasLayer

var meter_value = 0
var meter_max = 100
var increase_speed = 1 # units per second

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	meter_value += increase_speed * delta
	if meter_value > meter_max:
		meter_value = meter_max
	$CorruptionMeter.value = meter_value
