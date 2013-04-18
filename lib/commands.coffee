
lirc	= require './lirc'
cluster	= require 'cluster'

{merge, clone, typeOf, empty, toArray} = lirc.utils

lirc.send = () ->
	if not lirc.session.conn
		return lirc.error 'err', "lirc.commands, no lirc.session.conn"

	text = toArray( arguments ).join ' '
	text = lirc.format.substitute.vars text

	str = text + '\r\n'

	lirc.session.conn.write str

	msg = {
		cmd: 'SEND'
		text: str
		time: new Date().getTime()
	}

	lirc.botnet.emit.master {
		cmd	: 'emit.web'
		args: ['msg', [msg]]
	}

	return true

lirc.auth = (user) ->
	{user} = lirc.session.server if not user

	userStr = [
		user.username
		user.hostname or user.username
		user.server or user.username
		':' + user.realname
	].join ' '

	if user.pass
		lirc.send 'PASS', user.pass

	lirc.send 'NICK', user.nick
	lirc.send 'USER', userStr

lirc.send.privmsg = (target, text = '') ->
	lirc.send 'PRIVMSG', target, ":#{text}"

lirc.send.mode = (target, text) -> # TODO: need to parse add arguments
	return false if not text

	lirc.send 'MODE', target, text

lirc.join = (chans, chanKey) ->
	chans = chans or lirc.cfg.chans # TODO: cfg format not stable

	return false if empty chans

	if typeOf( chans ) is 'string'
		if chanKey
			chans = [[chans, chanKey]] # TODO: may want to change format to objects
		else
			chans = [chans]

	lists = {
		chans	: []
		keys	: []
	}

	for chan in chans
		if typeOf( chan ) is 'array'
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

	if typeOf( chans ) is 'string'
		chans = [chans]
	
	list = []
	for chan in chans
		if typeOf( chan ) is 'array'
			list.push chan[0]
		else
			list.push chan

	text = list.join ','

	lirc.send 'PART', text

lirc.quit = (message = 'lirc') ->
	lirc.send 'QUIT :' + message
	
	lirc.session.conn.end()

