extends CharacterBody3D;
class_name Entity;

@export var has_gravity:bool = true;
@export var can_think:bool = true;

@export var speed:float = 5; #in meters per sec
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
	var next_loc_local := next_loc - global_position;
	
	var dir := next_loc_local.normalized();
	velocity = dir * speed;
	move_and_slide();

func _process_gravity(delta:float) -> void:
	velocity += get_gravity() * delta;

func _ready() -> void:
	position = terrain.get_path_start();

func _physics_process(delta: float) -> void:
	if has_gravity: _process_gravity(delta);
	if can_think and is_on_floor(): navigate();
	move_and_slide();


func _on_navigator_target_reached() -> void:
	queue_free();
