# DifficultyManager.gd
extends Node

var speed_multiplier: float = 1.0

@export var penalty_per_hit: float = 0.3      # wie stark jeder Treffer den Multiplikator drückt
@export var max_penalty: float = 0.85         # Obergrenze, damit nie auf ~0 Speed gefallen wird
@export var penalty_recover_rate: float = 0.12 # wie schnell sich der Penalty pro Sekunde abbaut

var _dip_penalty: float = 0.0   # 0 = kein Penalty, höher = langsamer
var _boost_value: float = 1.0
var _boost_tween: Tween

## Jeder Aufruf STAPELT auf den bestehenden Penalty, statt ihn zu ersetzen.
## Braucht bei hohem angesammeltem Penalty entsprechend mehr Zeit zur Erholung.
func speed_dip(amount: float = -1.0) -> void:
	var add_amount: float = amount if amount >= 0.0 else penalty_per_hit
	_dip_penalty = clamp(_dip_penalty + add_amount, 0.0, max_penalty)
	_update_multiplier()

func speed_boost(boost_to: float = 1.4, recover_time: float = 0.8) -> void:
	if _boost_tween:
		_boost_tween.kill()
	_boost_value = boost_to
	_update_multiplier()
	_boost_tween = create_tween()
	_boost_tween.tween_method(_set_boost_value, boost_to, 1.0, recover_time) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func _set_boost_value(v: float) -> void:
	_boost_value = v
	_update_multiplier()

func _process(delta: float) -> void:
	if _dip_penalty > 0.0:
		_dip_penalty = max(0.0, _dip_penalty - penalty_recover_rate * delta)
		_update_multiplier()

func _update_multiplier() -> void:
	speed_multiplier = (1.0 - _dip_penalty) * _boost_value
