
lirc = require './lirc'

{type} = Function


format = {
	log: (msg) ->
		{from, to}	= msg

		if msg.from is lirc.session.server.realhost
			from = 'server'

		if to is lirc.session.server.user.nick
			to = 'me'

		route	= "#{ from }#{ if to then ' > ' + to }"
		route	+= ' ' if route

		content	= msg.words.join ' '

		#result = "#{ route }'#{ msg.command }' #{ content }"
		result = "[#{ msg.cmd }] #{ content }"

		return result

	nick: (nick = '') ->
		return nick if not nick

		nick = lirc.format.substitute.randomNumbers nick, /[#?]/g

		return nick

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

format.substitute.vars.vars = { # will be added to by each module
}

lirc.format		=
module.exports	= format