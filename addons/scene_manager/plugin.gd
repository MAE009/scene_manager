extends EditorPlugin

var scene_manager

func _enter_tree():
	scene_manager = load("res://scene_manager/addons/scene_manager/scene_manager.gd").new()
	get_tree().root.add_child(scene_manager)
	print("SceneManager Plugin activé")

func _exit_tree():
	if scene_manager:
		scene_manager.queue_free()
