extends CharacterBody2D

var mapa: Node2D

@export var velocidad_suavizado: float = 15.0
@export var velocidad_desliz: float = 625.0
@export var aceleracion_desliz: float =  0.3
@export var altura_salto: float = 200.0 
@export var duracion_salto: float = 0.8
@export var distancia_buffer: float = 70.0

@export_group("Sonidos")
@export var sonido_andar: AudioStream
@export var sonido_deslizar: AudioStream
@export var sonido_federico_on: AudioStream
@export var sonido_federico_goku: AudioStream
@export var sonidos_aleatorios_normales: Array[AudioStream] = []
@export var sonido_risa_locura: AudioStream
@export var sonido_muerte: AudioStream
@export var intervalo_aleatorio_min: float = 4.0
@export var intervalo_aleatorio_max: float = 9.0

var reproductor_aleatorio_normal: AudioStreamPlayer
var timer_aleatorio: Timer
var camara_posicion: Vector2
const federico_on: Texture2D = preload("res://assets/sprites/federico_cargado.png")
const federico_goku: Texture2D = preload("res://assets/sprites/federico_cargado_ssj.png")

var direcciones = {
	"derecha": Vector2i(1, 0),
	"arriba": Vector2i(0, -1),
	"izquierda": Vector2i(-1, 0),
	"abajo": Vector2i(0, 1)
}
var direccion_jugador: Vector2i
var deslizando: bool = false
var saltando: bool = false
var tirando: bool = false
var muriendo: bool = false
var derecha: bool = true
var lava: bool = false
var suave_camara: bool = false
var buffer: bool = false
var dir_buffer: Vector2i
var velocidad_actual_desliz: float 

func _ready() -> void:
	$AnimatedSprite2D.play("quieto_derecha")
	Global.locura = 0
	
	timer_aleatorio = Timer.new()
	timer_aleatorio.one_shot = true
	add_child(timer_aleatorio)
	timer_aleatorio.timeout.connect(_on_timer_aleatorio_timeout)
	_reiniciar_timer_aleatorio()
	camara_posicion = mapa.camara.position
	
func reproducir_sonido(sonido: AudioStream, es_aleatorio_normal: bool = false) -> void:
	if not sonido:
		return
	var player := AudioStreamPlayer.new()
	if sonido == sonido_deslizar:
		player.volume_db = -15.0
	player.stream = sonido
	add_child(player)
	player.finished.connect(player.queue_free)
	if es_aleatorio_normal:
		reproductor_aleatorio_normal = player
	player.play()

func _reiniciar_timer_aleatorio() -> void:
	timer_aleatorio.start(randf_range(intervalo_aleatorio_min, intervalo_aleatorio_max))

func _on_timer_aleatorio_timeout() -> void:
	if not muriendo:
		if Global.locura_on:
			reproducir_sonido(sonido_risa_locura)
		elif sonidos_aleatorios_normales.size() > 0:
			reproducir_sonido(sonidos_aleatorios_normales.pick_random(), true)
	_reiniciar_timer_aleatorio()

func _process(delta: float) -> void:
	if Global.locura_on and is_instance_valid(reproductor_aleatorio_normal) and reproductor_aleatorio_normal.playing:
		reproductor_aleatorio_normal.stop()
	if not mapa:
		return
	if mapa.camara_on and not saltando:
		suavizar_camara(delta)
		mapa.camara.position = camara_posicion
	interactuar()
	apuntar()
	var celda_actual: Vector2i = mapa.posicion_a_celda(position)
	if not saltando:
		mapa.recoger_en(celda_actual)
		if mapa.es_lava(celda_actual) and z_index != 2:
			lava = true
	if deslizando and Global.efecto != Global.Efectos.MANTEQUILLA:
		Global.posicion_jugador = celda_actual
	morir_por_locura()
	if muriendo:
		return
	var pos_destino: Vector2 = mapa.celda_a_posicion(Global.posicion_jugador)
	
	if not saltando:
		if deslizando:
			velocidad_actual_desliz += aceleracion_desliz * delta
			position = position.move_toward(pos_destino, velocidad_actual_desliz * delta)
			camara_posicion += Vector2(direccion_jugador) * velocidad_actual_desliz * delta
		elif suave_camara:
			position = position.lerp(pos_destino, velocidad_suavizado * delta)
			camara_posicion += (pos_destino - camara_posicion) * delta * 3.5
		else:
			position = position.move_toward(pos_destino, 0.6 * velocidad_desliz * delta)
			if tirando:
				camara_posicion += Vector2(direccion_jugador) * velocidad_desliz * delta * 0.6

	buffer_input(position, pos_destino)

	if position.distance_to(pos_destino) < 0.5 and not saltando:
		position = pos_destino
		deslizando = false
		tirando = false  
		suave_camara = true
		z_index = 0
		mapa.terminar_nivel()
		morir()
		if buffer:
			direccion_jugador = dir_buffer
			if direccion_jugador == direcciones.derecha:
				$AnimatedSprite2D.play("quieto_derecha")
				derecha = true
			elif direccion_jugador == direcciones.izquierda:
				$AnimatedSprite2D.play("quieto_izquierda")
				derecha = false
			mover()
			buffer = false

# Definición:
func suavizar_camara(delta: float) -> void:
	if not suave_camara:
		var aux: Vector2 = camara_posicion - position
		if aux.length() > 0.15:
			camara_posicion = camara_posicion.lerp(position, 3.0 * delta)
		else:
			camara_posicion = position

func apuntar():
	if not deslizando and not saltando and not muriendo and not lava and not tirando:
		if Input.is_action_just_pressed("right"):
			direccion_jugador = direcciones.derecha
			$AnimatedSprite2D.play("quieto_derecha")
			derecha = true
			mover()
		elif Input.is_action_just_pressed("left"):
			direccion_jugador = direcciones.izquierda
			$AnimatedSprite2D.play("quieto_izquierda")
			derecha = false
			mover()
		elif Input.is_action_just_pressed("up"):
			direccion_jugador = direcciones.arriba
			mover()
		elif Input.is_action_just_pressed("down"):
			direccion_jugador = direcciones.abajo
			mover()

func buffer_input(posicion: Vector2, destino: Vector2):
	if (saltando or deslizando or tirando) and posicion.distance_to(destino) < distancia_buffer:
		if Input.is_action_just_pressed("right") and direccion_jugador != direcciones.derecha:
			dir_buffer = direcciones.derecha
			buffer = true
		elif Input.is_action_just_pressed("left") and direccion_jugador != direcciones.izquierda:
			dir_buffer = direcciones.izquierda
			buffer = true
		elif Input.is_action_just_pressed("up") and direccion_jugador != direcciones.arriba:
			dir_buffer = direcciones.arriba
			buffer = true
		elif Input.is_action_just_pressed("down") and direccion_jugador != direcciones.abajo:
			dir_buffer = direcciones.abajo
			buffer = true

func interactuar():
	if not muriendo:
		if Global.efecto == Global.Efectos.FEDERICO:
			if Input.is_action_just_pressed("interactuar"):
				if Global.federico == Global.Federico.OFF:
					Global.federico = Global.Federico.ON
					print("ON")
				elif Global.federico == Global.Federico.ON:
					Global.federico = Global.Federico.GOKU
					print("GOKU")
				elif Global.federico == Global.Federico.GOKU:
					Global.federico = Global.Federico.OFF
					print("OFF")

func mover():
	if mapa and (Global.hambre > 0 or Global.locura_on):
		if Global.efecto == Global.Efectos.BASE:
			if mapa.es_transitable(Global.posicion_jugador + direccion_jugador):
				suave_camara = true                      
				Global.posicion_jugador += direccion_jugador
				Global.hambre -= 1
				reproducir_sonido(sonido_andar)
		elif Global.efecto == Global.Efectos.MANTEQUILLA:
			if mapa.es_transitable(Global.posicion_jugador + direccion_jugador):
				suave_camara = false                     
				Global.posicion_jugador = mapa.calcular_desliz(Global.posicion_jugador, direccion_jugador)
				deslizando = true
				velocidad_actual_desliz = velocidad_desliz
				Global.hambre -= 1
				reproducir_sonido(sonido_deslizar)
		elif Global.efecto == Global.Efectos.FEDERICO and mapa.es_saltable(Global.posicion_jugador, direccion_jugador):
			if Global.federico == Global.Federico.GOKU:
				suave_camara = false                     
				var inicio: Vector2 = mapa.celda_a_posicion(Global.posicion_jugador)
				Global.posicion_jugador += 4 * direccion_jugador
				var destino: Vector2 = mapa.celda_a_posicion(Global.posicion_jugador)
				animar_federico_goku(inicio, destino)
				animar_salto(destino)
				Global.hambre -= 1
				reproducir_sonido(sonido_federico_goku)
				
			elif Global.federico == Global.Federico.OFF:
				suave_camara = true                      
				Global.posicion_jugador += direccion_jugador
				Global.hambre -= 1
				reproducir_sonido(sonido_andar)
				
			elif Global.federico == Global.Federico.ON:
				suave_camara = false
				tirando = true
				y_sort_enabled = false
				z_index = 2
				Global.posicion_jugador += 2 * direccion_jugador
				animar_federico_on(mapa.celda_a_posicion(Global.posicion_jugador))
				Global.hambre -= 1
				reproducir_sonido(sonido_federico_on)

func animar_salto(destino: Vector2) -> void:
	y_sort_enabled = false
	z_index = 2
	saltando = true
	var tween := create_tween().set_parallel(true)
	tween.tween_method(arco.bind(position, destino), 0.0, 1.0, duracion_salto)
	if mapa.camara_on:
		tween.tween_property(mapa.camara, "position", destino, duracion_salto)
	await tween.finished
	$AnimatedSprite2D.position.y = 0.0
	if mapa.camara_on:
		camara_posicion = mapa.camara.position
	position = destino
	saltando = false
	y_sort_enabled = true
	z_index = 1

func arco(t: float, inicio: Vector2, destino: Vector2) -> void:
	position = inicio.lerp(destino, t)
	$AnimatedSprite2D.position.y = -4.0 * altura_salto * t * (1.0 - t)

func crear_sprite_federico(textura: Texture2D, pos: Vector2, prioridad_z: int) -> Sprite2D:
	var fede := Sprite2D.new()
	fede.texture = textura
	fede.position = pos
	fede.z_index = prioridad_z
	if direccion_jugador.x != 0:
		fede.flip_h = derecha
	fede.scale = Vector2.ZERO
	fede.modulate.a = 0.0
	mapa.add_child(fede)
	return fede

func animar_federico_on(destino: Vector2) -> void:
	var dir := Vector2(direccion_jugador)
	var pos_tiron: Vector2 = destino + dir * 10.0
	var pos_final_tiron: Vector2 = pos_tiron + dir * 8.0
	var fede := crear_sprite_federico(federico_on, pos_tiron, 4)

	var tween := create_tween()
	tween.tween_property(fede, "scale", Vector2.ONE, 0.12).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(fede, "modulate:a", 1.0, 0.1)
	tween.tween_property(fede, "position", pos_final_tiron, 0.12).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(fede, "scale", Vector2(1.15, 0.88), 0.12)
	tween.tween_property(fede, "scale", Vector2.ZERO, 0.15).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(fede, "modulate:a", 0.0, 0.15)
	tween.parallel().tween_property(fede, "position:y", pos_final_tiron.y - 8.0, 0.15)
	tween.tween_callback(fede.queue_free)

func animar_federico_goku(inicio: Vector2, destino: Vector2) -> void:
	var punto_medio: Vector2 = (inicio + destino) / 2.0
	var fede := crear_sprite_federico(federico_goku, punto_medio, 1)
	var tween := create_tween()
	tween.tween_property(fede, "scale", Vector2.ONE, duracion_salto * 0.25).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(fede, "modulate:a", 1.0, duracion_salto * 0.2)
	tween.tween_property(fede, "position:y", punto_medio.y + 10.0, duracion_salto * 0.15).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(fede, "scale", Vector2(1.22, 0.78), duracion_salto * 0.15)
	tween.tween_property(fede, "position:y", punto_medio.y - 6.0, duracion_salto * 0.35).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(fede, "scale", Vector2.ZERO, duracion_salto * 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
	tween.parallel().tween_property(fede, "modulate:a", 0.0, duracion_salto * 0.35)
	tween.tween_callback(fede.queue_free)

func morir() -> void:
	if muriendo:
		return
	if (Global.hambre == 0 and not Global.locura_on) or lava:
		iniciar_muerte()

func morir_por_locura() -> void:
	if muriendo or mapa.es_meta(Global.posicion_jugador):
		return
	if Global.locura >= mapa.locura_maxima:
		iniciar_muerte()

func iniciar_muerte() -> void:
	lava = false
	buffer = false
	var lilbro = $AnimatedSprite2D
	muriendo = true
	reproducir_sonido(sonido_muerte)
	if not derecha:
		lilbro.flip_h = true
	lilbro.play("muerto")
	var angulo_caida: float = -90.0 if direccion_jugador.x < 0 else 90.0
	var tween := create_tween()
	tween.tween_property(lilbro, "rotation_degrees", angulo_caida, 0.6).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	tween.parallel().tween_property(lilbro, "position:y", 16.0, 0.6).set_trans(Tween.TRANS_BOUNCE).set_ease(Tween.EASE_OUT)
	
	await tween.finished
	await get_tree().create_timer(1.5).timeout
	muriendo = false
	Global.muerto = true
