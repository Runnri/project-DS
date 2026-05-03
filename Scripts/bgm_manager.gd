extends Node

# ============================================================
# BGM MANAGER — Autoload
# Tambahkan di project.godot:
# BgmManager="*res://Scripts/bgm_manager.gd"
#
# Peletakan musik:
# res://Assets/audio/bgm_lobby.mp3
# res://Assets/audio/menuju_ending.mp3
# res://Assets/audio/ending.mp3
# ============================================================

var _player: AudioStreamPlayer
var _track_aktif: String = ""

func _ready():
	_player = AudioStreamPlayer.new()
	_player.bus = "Master"
	add_child(_player)

func play(track: String):
	if track == _track_aktif:
		return
	_track_aktif = track

	var path := ""
	match track:
		"lobby":         path = "res://Assets/audio/bgm_lobby.mp3"
		"ingame":        path = "res://Assets/audio/ingame.mp3"
		"menuju_ending": path = "res://Assets/audio/menuju_ending.mp3"
		"ending":        path = "res://Assets/audio/ending.mp3"
		"stop":
			_player.stop()
			return

	if not ResourceLoader.exists(path):
		push_warning("[BGM]: File tidak ditemukan: " + path)
		return

	_player.stream = load(path)
	var stream = _player.stream
	if stream is AudioStreamMP3:
		stream.loop = track != "ending"
	_player.play()

func stop():
	play("stop")

func fade_to(track: String, durasi: float = 1.0):
	if _player.playing:
		var tw = create_tween()
		tw.tween_property(_player, "volume_db", -60.0, durasi)
		tw.tween_callback(func():
			_player.volume_db = 0.0
			play(track)
		)
	else:
		play(track)
