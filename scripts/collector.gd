extends Node
class_name collector

@onready var game = $".."
@onready var generator = $"../DungeonGenerator3D"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	generator.connect("done_generating",_player_activity)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _player_activity():
	pass
