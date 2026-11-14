extends Node

var posicion_jugador: Vector2i
var hambre: int
enum TipoObjeto {PAN, MANTEQUILLA, FEDERICO, BOTON, PANCONPAN, PANFINAL, LLAVE, SECRETO}
enum Efectos {BASE, MANTEQUILLA, FEDERICO}
enum Federico {OFF, ON, GOKU}
var locura_on: bool
var federico: Federico
var efecto: Efectos
var muerto: bool
var locura: int
var secreto: bool = false
var secreto_on: bool = false
var tuto_federico_visto: bool = false
var modo_dev = false
var nivel_alcanzado: int = 0
