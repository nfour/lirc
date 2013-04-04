
lirc		= require './lirc'

{type} = Function

lirc.format = {
	log: (msg) ->
		ary = []

		ary.push "[ #{msg.cmd} ]"
		ary.push "remains=\"#{msg.remains}\"" if msg.remains

		for key, val of msg
			if key.match /^(raw|words|cmd|remains|origin)$/ then continue
			if key is 'target22'
				continue if not val or val is lirc.session.server.user.nick
			ary.push "#{key}=\"#{val}\""

		result = ary.join ', '

		return result

	nick: (nick = '') ->
		return nick if not nick

		nick = lirc.format.substitute.randomNumbers nick, /[#?]/g

		return nick

	stripColors: (str) ->
		return str.replace /[\x02\x1f\x16\x0f]|\x03\d{0,2}(?:,\d{0,2})?/g, ''

	substitute: {
		vars: (text) ->
			for varName, val of lirc.format.substitute.vars.vars
				if val
					text = text.replace "\\b\\$#{ varName }\\b", val

			return text

		randomNumbers: (str, subChar) ->
			return str if not str or not subChar

			chars = str.split ''
			for char, index in chars
				if char.match subChar
					chars[index] =  Math.floor Math.random() * (9 - 0 + 1)

			return chars.join ''
	}
}

lirc.format.substitute.vars.vars = { # will be added to by each module

}

