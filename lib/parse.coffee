
lirc	= require './lirc'
codes	= require './codes'

{merge, clone} = Object
{type} = Function

# This definition of "parse": Deconstruct something, then use that to
# do something else and/or simply return the deconstruction

rawBuffer		= null
mappingIndexes	= {}

lirc.parse = {
	raw: (text = '') ->
		return text if type( text ) isnt 'string'

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
		}

		# [:<origin>] <cmd> [<args>] [:<text>]
		if msg and m = raw.match ///
			^ (?: :(\S+) \s )?						# origin
			(\S+)									# cmd
			(?: \s
				(?: ( [^:]+ ) )?		# args
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
			if cmd is key then cmd = codes[key]

		return cmd

	mapping: (name, msg) ->
		mapping = lirc.mappings[ name ] or undefined

		if not mapping
			return console.error "Mapping '#{name}' not defined"

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

lirc.bind = (obj, emitter) ->
	return emitter if not emitter
	
	objType = type( obj )

	if objType is 'object'
		for key of obj
			emitter.on key, obj[key]
		
	else if objType is 'array'
		for key of obj
			emitter.on obj[key][0], obj[key][1]

	return emitter
