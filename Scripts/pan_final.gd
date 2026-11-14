extends "res://Scripts/recogible.gd"


func aplicar_efecto() -> void:
	if not Global.secreto_on:
		get_tree().change_scene_to_file("res://Scenes/final_bueno.tscn")
	else:
		Global.hambre += 10
