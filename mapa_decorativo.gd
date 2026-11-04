extends Node2D
@onready var mapa_decorativo: TileMapLayer = $mapa_decorativo

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func es_transitable_dec(pos: Vector2i) -> bool:
	var datos: TileData = mapa_decorativo.get_cell_tile_data(pos)
	return datos != null and not datos.get_custom_data("intransitable")
