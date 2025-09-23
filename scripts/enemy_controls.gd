extends Node
class_name enemy_control

@onready var generator = $"../DungeonGenerator3D"
@onready var game = $".."
var control = controls.new()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func work_with_enemies(game_node, living_rooms: Array[DungeonRoom3D]):
	# getting the detections regions
	var enemy_regions: Array[Area3D]
	for room in living_rooms:
		var region = room.get_node("enemy_detection_region")
		enemy_regions.append(region)
	
	# now do the enemy spawning and despawning 
	for space in enemy_regions:
		space.body_entered.connect(func(body):
			game_node.spawn_enemies(space, body)
		)
		space.body_exited.connect(func(body):
			game_node.despawn_enemies(space, body)
		)
	
func player_death_region(game_node, enemies: Array[CharacterBody3D]):
	var death_regions: Array[Area3D]
	for enemy in enemies:
		death_regions.append(enemy.get_node("player_death_region"))
	
	for death_region in death_regions:
		death_region.body_entered.connect(game_node.player_dead)
