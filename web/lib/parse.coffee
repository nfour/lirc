
web = require './web'

{merge, clone} = Object
{type} = Functions

web.parse = {
	input: (text = '') ->
		return text if type( text ) isnt 'string'

		lines = text.split '\r\n'

		if msgBuffer
			lines[0]	= msgBuffer + lines[0]
			msgBuffer	= null

		if not text.match /\r\n$/
			msgBuffer	= lines[-1..][0]
			lines		= lines[..-2]

		for line in lines
			msg = lirc.format.msg line

			for name, mapping of lirc.mappings
				parse.mapping name, mapping, msg

		return msg
}
