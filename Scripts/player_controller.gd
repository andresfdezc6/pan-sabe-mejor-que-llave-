extends CharacterBody2D

var mapa: Node2D 

@export var velocidad_suavizado: float = 15.0

var direcciones = {
	"derecha": Vector2i(1, 0),
	"arriba": Vector2i(0, -1),
	"izquierda": Vector2i(-1, 0),
	"abajo": Vector2i(0, 1)
}

var direccion_jugador: Vector2i

func _process(delta: float) -> void:
	apuntar()
	
	# Interpola la posición física hacia la casilla lógica global actual
	if mapa:
		var pos_destino = mapa.celda_a_posicion(Global.posicion_jugador)
		position = position.lerp(pos_destino, velocidad_suavizado * delta)

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
	if mapa and mapa.es_transitable(Global.posicion_jugador + direccion_jugador) and Global.hambre > 1:
		Global.posicion_jugador += direccion_jugador
		Global.hambre -= 1
		print(Global.hambre)
	
	
	
	
	
