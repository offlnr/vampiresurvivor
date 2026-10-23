extends Node
## Plays sound effects from a fixed set of voices per sound, plus one music track.

## A sound effect started; the online host forwards it to the guest (see NetHost).
signal played(sound: StringName, volume_db: float)

const SOUNDS := {
	&"hit": preload("res://art/placeholder/audio/hit.wav"),
	&"enemy_die": preload("res://art/placeholder/audio/enemy_die.wav"),
	&"pickup": preload("res://art/placeholder/audio/pickup.wav"),
	&"level_up": preload("res://art/placeholder/audio/level_up.wav"),
	&"hurt": preload("res://art/placeholder/audio/hurt.wav"),
	&"throw": preload("res://art/placeholder/audio/throw.wav"),
	&"bats": preload("res://art/placeholder/audio/bats.wav"),
	&"click": preload("res://art/placeholder/audio/click.wav"),
	&"game_over": preload("res://art/placeholder/audio/game_over.wav"),
	&"victory": preload("res://art/placeholder/audio/victory.wav"),
	&"alert": preload("res://art/placeholder/audio/alert.wav"),
	&"slash": preload("res://art/placeholder/audio/slash.wav"),
	&"fire": preload("res://art/placeholder/audio/fire.wav"),
	&"chest": preload("res://art/placeholder/audio/chest.wav"),
	&"coin": preload("res://art/placeholder/audio/coin.wav"),
	&"buy": preload("res://art/placeholder/audio/buy.wav"),
	&"powerup": preload("res://art/placeholder/audio/powerup.wav"),
	&"boom": preload("res://art/placeholder/audio/boom.wav"),
	&"tick": preload("res://art/placeholder/audio/tick.wav"),
	&"lightning": preload("res://art/sfx/lightning.wav"),
	&"vortex": preload("res://art/sfx/vortex.wav"),
	&"blunderbuss": preload("res://art/sfx/blunderbuss.wav"),
	&"embers": preload("res://art/sfx/embers.wav"),
}
const VOICES_PER_SOUND := 4
## Minimum time between two starts of the same sound, so a crowd of enemies doesn't saturate the mix.
const MIN_INTERVAL := 0.045

## Seconds each playlist track takes to fade in.
const MUSIC_FADE_IN := 1.2

var _voices := {}
var _last_played := {}
var _music: AudioStreamPlayer
## Playlist tracks ({stream, volume_db}), the shuffled order and the position in it.
var _playlist: Array[Dictionary] = []
var _order: Array[int] = []
var _track := -1
var _fade: Tween


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	for key: StringName in SOUNDS:
		var voices: Array[AudioStreamPlayer] = []
		for i in VOICES_PER_SOUND:
			var player := AudioStreamPlayer.new()
			player.stream = SOUNDS[key]
			player.bus = &"SFX"
			add_child(player)
			voices.append(player)
		_voices[key] = voices
	_music = AudioStreamPlayer.new()
	_music.bus = &"Music"
	_music.finished.connect(_next_track)
	add_child(_music)


func play(sound: StringName, pitch_jitter := 0.08, volume_db := 0.0) -> void:
	var now := Time.get_ticks_msec() / 1000.0
	if now - _last_played.get(sound, -1.0) < MIN_INTERVAL:
		return
	for player: AudioStreamPlayer in _voices.get(sound, []):
		if not player.playing:
			player.pitch_scale = 1.0 + randf_range(-pitch_jitter, pitch_jitter)
			player.volume_db = volume_db
			player.play()
			_last_played[sound] = now
			played.emit(sound, volume_db)
			return


func _exit_tree() -> void:
	# Let go of the music still playing when the game closes, so nothing is left behind.
	_music.stop()
	_music.stream = null


## Plays one track on repeat (the menu's ambience).
func play_music(stream: AudioStream) -> void:
	if _playlist.is_empty() and _music.stream == stream and _music.playing:
		return
	_playlist = []
	_set_fade(0.0)
	_music.stream = stream
	_music.volume_db = 0.0
	_music.play()


## Plays the tracks one after another in a shuffled order, reshuffling when the list ends.
## Each track is {stream, volume_db}; volume_db evens out how loud the tracks are.
## Calling it again with the same list while it plays keeps the current track going.
func play_playlist(tracks: Array[Dictionary]) -> void:
	if tracks == _playlist and _music.playing:
		return
	_playlist = tracks
	_order = []
	_track = -1
	_next_track()


func stop_music() -> void:
	_playlist = []
	_set_fade(0.0)
	_music.stop()


func _next_track() -> void:
	if _playlist.is_empty():
		# A single looping track: start it again.
		if _music.stream != null:
			_music.play()
		return
	_track += 1
	if _track >= _order.size():
		var last: int = _order.back() if not _order.is_empty() else -1
		_order = []
		for i in _playlist.size():
			_order.append(i)
		_order.shuffle()
		# Never the same track twice in a row across reshuffles.
		if _order.size() > 1 and _order[0] == last:
			_order.append(_order.pop_front())
		_track = 0
	var entry: Dictionary = _playlist[_order[_track]]
	_music.stream = entry.stream
	_music.play()
	_set_fade(MUSIC_FADE_IN, entry.get("volume_db", 0.0))


## Fades the music in to `volume_db` over `seconds` (0 = no fade).
func _set_fade(seconds: float, volume_db := 0.0) -> void:
	if _fade != null and _fade.is_valid():
		_fade.kill()
	if seconds <= 0.0:
		return
	_music.volume_db = -40.0
	_fade = create_tween()
	_fade.tween_property(_music, "volume_db", volume_db, seconds).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_QUAD)


## The track playing now, or null (for tests and debugging).
func current_music() -> AudioStream:
	return _music.stream if _music.playing else null
