extends Node2D

@export var escena_jugador: PackedScene = preload("res://Scenes/jugador.tscn")
@onready var mapa: TileMapLayer = $mapa_base
@onready var mapa_obstaculos: TileMapLayer = $mapa_obstaculos
@export var posicion_inicial: Vector2i = Vector2i(0, 0)
@onready var camara: Camera2D = $Camera2D
@export var hambre_inicial = 15

var jugador_instancia: CharacterBody2D


func _ready() -> void:
	Global.posicion_jugador = posicion_inicial
	Global.hambre = hambre_inicial
	jugador_instancia = escena_jugador.instantiate()
	jugador_instancia.mapa = self
	add_child(jugador_instancia)
	jugador_instancia.position = celda_a_posicion(Global.posicion_jugador)
	
func centrar_camara_en_puzle() -> void: #CAMARA
	if not mapa or not camara:
		return

	# Obtiene el área que ocupan las baldosas en el mapa
	var rect_celdas: Rect2i = mapa.get_used_rect()
	var tamano_tile: Vector2i = mapa.tile_set.tile_size

	# Calcula las coordenadas del centro en píxeles del mundo
	var centro_x = (rect_celdas.position.x + (rect_celdas.size.x / 2.0)) * tamano_tile.x
	var centro_y = (rect_celdas.position.y + (rect_celdas.size.y / 2.0)) * tamano_tile.y

	camara.position = Vector2(centro_x, centro_y)

func celda_a_posicion(pos: Vector2i) -> Vector2:
	if mapa:
		return mapa.map_to_local(pos)
	return Vector2 (0,0)

func es_transitable(pos: Vector2i) -> bool:
	var datos_1: TileData = mapa.get_cell_tile_data(pos)
	var datos_2: TileData = mapa_obstaculos.get_cell_tile_data(pos)
	
	var suelo_valido = datos_1 != null and datos_1.get_custom_data("transitable")
	var es_bloqueado = datos_2 != null and datos_2.get_custom_data("intransitable")
	
	return suelo_valido and not es_bloqueado
	
