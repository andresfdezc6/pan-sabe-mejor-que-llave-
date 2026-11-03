extends Node2D
@onready var mapa: TileMapLayer = $mapa_base
@export var posicion_inicial = Vector2i(0,0)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.posicion_jugador = posicion_inicial
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func es_transitable(pos: Vector2i) -> bool:
	var datos: TileData = mapa.get_cell_tile_data(pos)
	return datos != null and datos.get_custom_data("transitable")
	
