extends CharacterBody3D;
class_name Entity;

@export var has_gravity:bool;
@export var can_think:bool;

@export var speed:float = 10; #in meters per sec
@export var health:int = 100;

@export var terrain:TerrainGen;

@onready var nav:NavigationAgent3D = $navigator;

func damage(damage_amount:int) -> int:
	health -= damage_amount;
	return health;

func speed_multiplier(speed_mult:float) -> float:
	speed *= speed_mult;
	return speed;

func navigate() -> void:
	var endpoint := terrain.get_path_end();
	nav.target_position = endpoint;
	
	var next_loc := nav.get_next_path_position();
	velocity = next_loc * speed;
	move_and_slide();

func _process_gravity() -> void:
	velocity = get_gravity();

func _physics_process(delta: float) -> void:
	if has_gravity: _process_gravity();
	if can_think: navigate();
