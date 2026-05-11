extends Node

func exp_decay(a, b, speed, delta):
	var decay = speed * 25.0 # range 0.0 -> 25.0
	return b + (a - b) * exp(-decay * delta)

func camel_to_words(text: String) -> String:
	var result := ""

	for i in text.length():
		var c := text[i]

		if c == c.to_upper() and c != c.to_lower():
			if i != 0:
				result += " "

			result += c.to_lower()
		else:
			result += c

	return result
