
lirc	= require './lirc'
codes	= require './codes'

{merge, clone, typeOf} = lirc.utils

# This definition of "parse": Deconstruct something, then use that to
# do something else and/or simply return the deconstruction

rawBuffer		= null
mappingIndexes	= {}

lirc.parse = {
	raw: (text) ->
		return text if typeof text isnt 'string'

		lines = text.split '\r\n'

		if rawBuffer
			lines[0]	= rawBuffer + lines[0]
			rawBuffer	= null

		if not text.match /\r\n$/
			rawBuffer	= lines[-1..][0]
		
		lines.pop()

		for line in lines
			msg = lirc.parse.msg line

			lirc.parse.mapping 'parsing', msg	# cumulative argument parsing
			lirc.parse.mapping 'actions', msg	# pong replies, emits, etc.

			lirc.emit 'msg', msg

		return true

	msg: (raw = '') ->
		msg = {
			raw			: raw
			origin		: ''
			cmd			: 'UNKNOWN'
			args		: ''
			text		: ''
			time		: new Date().getTime()
		}

		# [:<origin>] <cmd> [<args>] [:<text>]
		if msg and m = raw.match ///
			^ (?: :(\S+) \s )?						# origin
			(\S+)									# cmd
			(?: \s
				(?: ( [^:]+ ) )?					# args
				(?: :(.*) )?						# text
			)?
		///
			msg.origin		= m[1] if m[1]
			msg.cmd			= m[2] if m[2]
			msg.args		= m[3].replace /\s$/, '' if m[3]
			msg.text		= m[4] if m[4]

			msg.cmd = lirc.parse.command msg.cmd if msg.cmd

		return msg

	command: (cmd) ->
		for key of codes
			if cmd is key
				return codes[key]

		return cmd

	mapping: (name, msg) ->
		mapping = lirc.mappings[ name ] or undefined

		return msg if not mapping

		index = mappingIndexes[ name ]?[ msg.cmd ]

		if index
			msg = mapping[ index ][1]( msg )
		else
			if name not of mappingIndexes then mappingIndexes[ name ] = {}

			for args, aryIndex in mapping
				if ( typeof args[0] is 'string' and args[0] is msg.cmd ) or msg.cmd.match args[0]
					if msg.cmd not of mappingIndexes[ name ]
						mappingIndexes[ name ][ msg.cmd ] = aryIndex

					args[1]( msg )
					break

		return msg

	mask: (mask = '') -> # Nick!userid@host.domain
		obj = {
			nick: ''
			ident: ''
			host: ''
			domain: ''
			raw: mask
		}

		if m = mask.match /// ^
			(.+) !~? 			# nick
			(.+) @				# ident
			([^\.]+) \.			# host
			(.+)				# domain
		///
			[
				obj.nick
				obj.ident
				obj.host
				obj.domain
			] = m[1..]

		return obj
}

lirc.format = {
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

lirc.format.substitute.vars.vars = {}

lirc.bind = (obj, emitter) ->
	return emitter if not emitter
	
	objType = typeOf( obj )

	if objType is 'object'
		for key of obj
			emitter.on key, obj[key]
		
	else if objType is 'array'
		for key of obj
			emitter.on obj[key][0], obj[key][1]

	return emitter
