extends Node

var active_music_stream: AudioStreamPlayer

@export_group("Main")
@export var clips: Node
@export var one_shots: Node
@export var audio_one_shot_scene: PackedScene


func play(audio_name: String, from_position: float = 0.0, restart: bool = false) -> void:
	if restart and active_music_stream and active_music_stream.name == audio_name:
		return

	active_music_stream = clips.get_node(audio_name)
	active_music_stream.play(from_position)


func play_audio_one_shot(audio_stream: AudioStream, volume_db: float = 0.0, pitch_scale: float = 0.0, from_position: float = 0.0) -> AudioOneShot:
	var audio_one_shot: AudioOneShot = audio_one_shot_scene.instantiate()
	audio_one_shot.stream = audio_stream
	audio_one_shot.volume_db = volume_db
	audio_one_shot.pitch_scale = pitch_scale if pitch_scale != 0.0 else get_random_pitch()
	audio_one_shot.from_position = from_position
	one_shots.add_child(audio_one_shot)
	return audio_one_shot


## Builds an AudioStreamRandomizer on the fly from a list of streams and
## plays it as a one-shot. Uses the Randomizer's own built-in random_pitch /
## random_volume_offset_db instead of our manual get_random_pitch(), so the
## pitch_scale on the AudioOneShot itself stays at 1.0 (unmodified) and all
## the variance comes from the Randomizer.
func play_random_one_shot(
	audio_streams: Array[AudioStream],
	volume_db: float = 0.0,
	from_position: float = 0.0,
	random_pitch: float = 1.2,
	random_volume_offset_db: float = 0.0) -> AudioOneShot:
	var randomizer := AudioStreamRandomizer.new()
	for stream in audio_streams:
		randomizer.add_stream(-1, stream) # -1 appends at the end

	randomizer.random_pitch = random_pitch
	randomizer.random_volume_offset_db = random_volume_offset_db

	var audio_one_shot: AudioOneShot = audio_one_shot_scene.instantiate()
	audio_one_shot.stream = randomizer
	audio_one_shot.volume_db = volume_db
	audio_one_shot.pitch_scale = 1.0 # let the Randomizer handle pitch variance
	audio_one_shot.from_position = from_position
	one_shots.add_child(audio_one_shot)
	return audio_one_shot


func get_random_pitch() -> float:
	randomize()
	return randf_range(0.8, 1.2)
