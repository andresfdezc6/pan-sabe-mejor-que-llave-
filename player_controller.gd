extends CharacterBody2D
@export var mapa: Node2D

var direcciones = {
	"derecha": Vector2i(1, 0),
	"arriba": Vector2i(0, -1),
	"izquierda": Vector2i(-1, 0),
	"abajo": Vector2i(0, 1)
}

var direccion_jugador: Vector2i

func _ready() -> void:
	await get_tree().process_frame
	if mapa:
		position = mapa.mapa.map_to_local(Global.posicion_jugador)

func _process(delta: float) -> void:
	apuntar()

func apuntar():
	if Input.is_action_just_pressed("right"):
		direccion_jugador = direcciones.derecha
		mover()
	elif Input.is_action_just_pressed("left"):
		direccion_jugador = direcciones.izquierda
		mover()
	elif Input.is_action_just_pressed("up"):
		direccion_jugador = direcciones.arriba
		mover()
	elif Input.is_action_just_pressed("down"):
		direccion_jugador = direcciones.abajo
		mover()

func mover():
	if mapa.es_transitable(Global.posicion_jugador + direccion_jugador):
		Global.posicion_jugador += direccion_jugador
		position = mapa.mapa.map_to_local(Global.posicion_jugador)
	
	
	
	
	
