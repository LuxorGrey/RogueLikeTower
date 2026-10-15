class_name StatValueColorizer
extends RefCounted

const POSITIVE_COLOR: String = "#75df8b"
const NEGATIVE_COLOR: String = "#f07872"

static func colorize(source_text: String) -> String:
	var value_pattern := RegEx.new()
	value_pattern.compile("(?i)[+＋−-]?\\s*\\d+(?:[.,]\\d+)?\\s*(?:%|daño|alcance|health|armor|shield|mana|gold|hex|s|ataques?|objetivos?)?")
	var matches: Array[RegExMatch] = value_pattern.search_all(source_text)
	var result := ""
	var cursor: int = 0
	for value_match in matches:
		var match_start: int = value_match.get_start(0)
		var match_end: int = value_match.get_end(0)
		var matched_value: String = value_match.get_string(0)
		if matched_value.strip_edges().is_empty():
			continue
		result += source_text.substr(cursor, match_start - cursor)
		var prefix_start: int = maxi(0, match_start - 48)
		var suffix_end: int = mini(source_text.length(), match_end + 40)
		var context: String = (
			source_text.substr(prefix_start, match_start - prefix_start)
			+ source_text.substr(match_end, suffix_end - match_end)
		).to_lower()
		var has_reduction_word: bool = (
			context.contains("menos")
			or context.contains("reduce")
			or context.contains("reducir")
			or context.contains("disminuye")
			or context.contains("recorta")
			or context.contains("baja")
		)
		var is_resource_saving: bool = has_reduction_word and (
			context.contains("mana")
			or context.contains("coste")
			or context.contains("costo")
			or context.contains("consumo")
			or context.contains("recarga")
			or context.contains("cooldown")
		)
		var cost_increase_word: bool = (
			context.contains("aumenta")
			or context.contains("aumentar")
			or context.contains("incrementa")
			or context.contains("eleva")
			or context.contains("sube")
		)
		var is_cost_increase: bool = cost_increase_word and (
			context.contains("coste")
			or context.contains("costo")
			or context.contains("consumo")
			or context.contains("cost ")
		)
		var is_damage_reduction_for_player: bool = (
			context.contains("daño recibido")
			or context.contains("daño que recibes")
			or context.contains("daño que recibe la base")
			or context.contains("daño que recibe la torre")
			or context.contains("daño que recibe el jugador")
		)
		var normalized_value: String = matched_value.strip_edges()
		var is_explicit_negative: bool = normalized_value.begins_with("-") or normalized_value.begins_with("−")
		var is_negative_effect: bool = (
			is_explicit_negative or has_reduction_word or is_cost_increase
		) and not is_resource_saving and not is_damage_reduction_for_player
		var color: String = NEGATIVE_COLOR if is_negative_effect else POSITIVE_COLOR
		result += "[color=%s]%s[/color]" % [color, matched_value]
		cursor = match_end
	result += source_text.substr(cursor)
	return result
