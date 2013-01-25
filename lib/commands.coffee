
lirc = require './lirc'

{merge, clone} = Object
{type, empty} = Function

lirc.send = () ->
	text = Array::slice.call( arguments ).join ' '
	text = lirc.format.substitute.vars text

	if lirc.session.conn
		str = text + '\r\n'

		lirc.session.conn.write str
		lirc.botnet.send.master 'emit::master', ['send', str]

		console.log '>>', str

		return true

	return false

lirc.join = (chans, chanKey) ->
	chans = chans or lirc.cfg.chans # TODO: cfg format not stable

	return false if empty chans

	if type( chans ) is 'string'
		if chanKey
			chans = [[chans, chanKey]] # TODO: may want to change format to objects
		else
			chans = [chans]

	lists = {
		chans	: []
		keys	: []
	}

	for chan in chans
		if type( chan ) is 'array'
			lists.chans.push chan[0]
			lists.keys.push chan[1] if chan[1]
		else
			lists.chans.push chan

	text = lists.chans.join ','
	text += ' ' + lists.keys.join ',' if lists.keys

	#@session.server.chans[] remember to add this shit when confirmation of chan join event pops

	lirc.send 'JOIN', text

lirc.part = (chans) ->
	chans = chans # TODO: session format not stable

	return false if not chans

	if type( chans ) is 'string'
		chans = [chans]
	
	list = []
	for chan in chans
		if type( chan ) is 'array'
			list.push chan[0]
		else
			list.push chan

	text = list.join ','

	lirc.send 'PART', text

lirc.quit = (message = 'lirc') ->
	lirc.send 'QUIT :' + message
	
	lirc.session.conn.end()

lirc.mode = (target, text) -> # TODO: need to parse add arguments
	return false if not text

	lirc.send 'MODE', target, text
