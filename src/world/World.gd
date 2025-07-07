extends Node3D

@onready var generation: TerrainGen = $Generation;

@export var enemies:Array[PackedScene];

func _spawn_enemy() -> void:
	var e:PackedScene = enemies.pick_random();
	var e_instance := e.instantiate();
	e_instance.terrain = generation;
	
	add_child(e_instance);
	

func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_accept"):
		_spawn_enemy();
