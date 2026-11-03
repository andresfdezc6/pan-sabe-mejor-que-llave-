extends CharacterBody2D

enum Direcciones {DERECHA, IZQUIERDA, ARRIBA, ABAJO}
var grid_position: Vector2i
var direccion_jugador: Direcciones

func _ready() -> void:
	grid_position = Vector2i(0,0)

func _process(delta: float) ->void:
	pass

func apuntar():
	if Input.is_action_pressed("right"):
		var direccion_jugador = Direcciones.DERECHA
	if Input.is_action_pressed("left"):
		var direccion_jugador = Direcciones.IZQUIERDA
	if Input.is_action_pressed("up"):
		var direccion_jugador = Direcciones.ARRIBA
	if Input.is_action_pressed("down"):
		var direccion_jugador = Direcciones.ABAJO
func comprobar_vecino(grid_position, direccion_jugador): 
	if direccion_jugador == Direcciones.DERECHA:
		pass
	elif direccion_jugador == Direcciones.IZQUIERDA:
		pass
	elif direccion_jugador == Direcciones.ARRIBA:
		pass
	elif direccion_jugador == Direcciones.ABAJO:
		pass
	
	
