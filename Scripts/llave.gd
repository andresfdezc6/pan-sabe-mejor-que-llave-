extends "res://Scripts/recogible.gd"

func aplicar_efecto() -> void:
	get_tree().change_scene_to_file("res://Scenes/final_malo.tscn")
