
lirc	= require './lirc'
codes	= require './codes'

{merge, clone} = Object
{type} = Function


msgBuffer		= null
mappingIndexes	= {}

parse = {
	data: (text = '') ->
		return text if type( text ) isnt 'string'

		lines = text.split '\r\n'

		if msgBuffer
			lines[0]	= msgBuffer + lines[0]
			msgBuffer	= null

		if not text.match /\r\n$/
			msgBuffer	= lines[-1..][0]
		
		lines.pop()

		for line in lines
			msg = lirc.parse.msg line

			parse.mapping 'parsing', msg
			parse.mapping 'actions', msg

			# emit to self and to the master ( only so that it may relay to the web interface )
			lirc.emit 'msg', msg
			lirc.botnet.send.master 'emit::master', ['msg', msg]	# may want to in future add cfg option to use
																	# 'emit', sending to master and all workers thus sharing all data
		return msg

	msg: (text = '') ->
		msg = {
			fulltext	: text
			from		: ''
			to			: ''
			cmd			: 'UNKNOWN'
			words		: []
		}

		return msg if not text

		words = text.split ' '
		
		if words[0][0] is ':'
			msg.from	= words[0].replace /^:/, ''
			words		= words[1..]

		return msg if not words.length

		msg.cmd		= lirc.parse.command words[0]
		words		= words[1..]

		msg.words = words

		return msg

	command: (cmd) ->
		for key of codes
			if cmd is key then cmd = codes[key]

		return cmd

	mapping: (name, msg) ->
		mapping = lirc.mappings[ name ] or undefined

		if not mapping
			return lirc.error 'Error', 'lirc.parse', "Mapping '#{ name }' not defined"

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
		}

		matches = mask.match /^(.+)!~?(.+)@([^\.]+)\.(.+)/
		matches.shift()

		if matches?.length
			[
				obj.nick
				obj.ident
				obj.host
				obj.domain
			] = matches

		return obj
}

lirc.bind = (obj, emitter) ->
	objType = type( obj )

	if objType is 'object'
		for key of obj
			emitter.on key, obj[key]
		
	else if objType is 'array'
		for key of obj
			emitter.on obj[key][0], obj[key][1]

	return emitter


lirc.parse		=
module.exports	= parse