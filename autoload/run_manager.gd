extends Node

enum Phase {
	RUN_SETUP,
	ROUND_PREP,
	COMBAT,
	ROUND_REWARD,
	TERRAIN_EXPANSION,
	CARD_OFFER,
	ROUND_TRANSITION,
	RUN_VICTORY,
	RUN_DEFEAT,
}

signal phase_changed(new_phase: int)

var phase: Phase = Phase.RUN_SETUP

func transition_to(next_phase: Phase) -> void:
	if phase == next_phase:
		return
	phase = next_phase
	phase_changed.emit(phase)
