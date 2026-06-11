extends Node
class_name SceneManager

# ============ SINGLETON ============
static var instance: SceneManager = null

# ============ CONFIG ============
@export var default_fade_color: Color = Color(0, 0, 0)
@export var default_fade_out_time: float = 0.3
@export var default_fade_in_time: float = 0.3

# Overlay fade actuel
var current_fade: ColorRect = null


# ============ INIT ============
func _ready():
	instance = self
	print("SceneManager prêt")


# ============ API PUBLIQUE ============

static func change_scene(scene_path: String,
	fade_color: Color = Color(0, 0, 0),
	fade_out_time: float = 0.3,
	fade_in_time: float = 0.3):

	var inst = _get_instance()
	if inst:
		inst._start_transition(scene_path, fade_color, fade_out_time, fade_in_time)
	else:
		push_error("SceneManager non initialisé")


static func go_to(scene_path: String):
	change_scene(scene_path)


static func transition_to(scene_path: String, fade_out: float = 0.3, fade_in: float = 0.3):
	change_scene(scene_path, Color(0, 0, 0), fade_out, fade_in)


# ============ INTERNAL ============
static func _get_instance() -> SceneManager:
	if instance == null:
		instance = Engine.get_main_loop().root.get_node_or_null("SceneManager")
	return instance


func _start_transition(scene_path: String, fade_color: Color, fade_out_time: float, fade_in_time: float):
	_create_fade(scene_path, fade_color, fade_out_time, fade_in_time)


# ============ FADE OUT ============
func _create_fade(scene_path: String, fade_color: Color, fade_out_time: float, fade_in_time: float):

	current_fade = ColorRect.new()
	current_fade.color = Color(fade_color.r, fade_color.g, fade_color.b, 0)
	current_fade.name = "SceneTransitionFade"

	current_fade.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	current_fade.z_index = 9999

	get_tree().root.add_child(current_fade)

	var tween = create_tween()
	tween.tween_property(current_fade, "color:a", 1.0, fade_out_time)

	tween.tween_callback(func():
		_load_scene(scene_path, fade_in_time)
	)


# ============ LOAD SCENE ============
func _load_scene(scene_path: String, fade_in_time: float):

	var scene = load(scene_path)
	if scene == null:
		push_error("Impossible de charger la scène: " + scene_path)
		_remove_fade()
		return

	get_tree().change_scene_to_packed(scene)

	call_deferred("_attach_fade_in", fade_in_time)


# ============ FADE IN ============
func _attach_fade_in(fade_in_time: float):

	await get_tree().process_frame

	if current_fade:
		get_tree().root.add_child(current_fade)

		var tween = create_tween()
		tween.tween_property(current_fade, "color:a", 0.0, fade_in_time)
		tween.tween_callback(_remove_fade)


# ============ CLEAN ============
func _remove_fade():
	if current_fade:
		current_fade.queue_free()
		current_fade = null
