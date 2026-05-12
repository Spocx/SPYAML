extends Node

func exp_decay(a, b, speed, delta):
	var decay = speed * 25.0 # range 0.0 -> 25.0
	return b + (a - b) * exp(-decay * delta)

func humanize_identifier(text: String) -> String:
	text = text.replace("_", " ")

	var result := ""

	for i in range(text.length()):
		var c = text[i]

		if i > 0:
			var prev = text[i - 1]

			var is_upper = is_uppercase(c)
			var prev_is_lower = is_lowercase(prev)
			var prev_is_upper = is_uppercase(prev)

			var next_is_lower = false

			if i < text.length() - 1:
				next_is_lower = is_lowercase(text[i + 1])

			var should_split = (
				(is_upper and prev_is_lower)
				or
				(is_upper and prev_is_upper and next_is_lower)
			)

			if should_split:
				result += " "

		result += c

	return result.capitalize()

func is_uppercase(c: String) -> bool:
	var n = c.unicode_at(0)
	return n >= 65 and n <= 90

func is_lowercase(c: String) -> bool:
	var n = c.unicode_at(0)
	return n >= 97 and n <= 122
	
func markdown_bold_to_bbcode(text: String) -> String:
	var regex := RegEx.new()
	regex.compile(r"\*\*(.*?)\*\*")
	return regex.sub(text, "[color=#a6e3a1]$1[/color]", true)
	
func extract_url(text: String) -> String:
	var regex := RegEx.new()

	regex.compile(
		r"\b((https?:\/\/)?(www\.)?([a-zA-Z0-9-]+\.)+[a-zA-Z]{2,}(\/[^\s]*)?)\b"
	)

	var result := regex.search(text)

	if result:
		return result.get_string()

	return ""
