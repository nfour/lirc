
# requires jquery >= 1.7.0

$$ = undefined

cfg = {
	scrollbar: {
		scrollInertia: 0
	}
	server: { # could also be a url. may be best to do this
		port: 8765
		host: 'localhost'
	}

	cmdChars: /[\.\+\-]/i

}

$(document).ready ->
	# create selectors
	$$ = {
		terminal		: $('.terminal')
		terminal_caret	: $('.terminal .caret')
		terminal_input	: $('.terminal .input input')

		tabs		: $('.tabs')
		tab_buttons	: $('.tabs .tab')
		tab_contents: $('.content .tab-content')

		content: $('.content')
	}

	# init mCustomScrollbar plugin
	$$.content.mCustomScrollbar cfg.scrollbar

	# scroll to the bottom of the feed (such as if there are buffered lines)
	terminal.scrollbar.scroll $$.content, 'bottom'

	server.conn = conn = io.connect "http://#{ cfg.server.host }:#{ cfg.server.port }"

	# bind listeners to the server
	bind server.listeners, conn

	# bind listeners to selectors
	bind terminal.input.listeners, $$.terminal_input

	terminal.buildTabs()

# scope variables

server = {
	conn: undefined

	listeners: {
		msg: (msg) ->
			console.log 'Recieved msg:', msg

			terminal.add 'all', server.prettyMsg msg

			if msg.cmd.match /^(BOTMSG|WEBMSG)$/i
				terminal.add 'botnet', server.prettyMsg msg
			else
				terminal.add 'irc', server.prettyMsg msg

		data: (data) ->
			console.log 'Recieved data:', data

			terminal.add 'raw_irc', data

		input: (data) ->
			console.log 'Recieved data:', data

			terminal.addInput data

		send: (data) ->
			terminal.addInput 'SEND ' + data # need to change addInput to addAll or something

		botmsg: (data) ->
			console.log 'Recieved data:', data

			terminal.add 'botnet', data
	}

	prettyMsg: (msg) ->
		{from, to, cmd, words} = msg

		if not ( from or to or cmd or words.join('') )
			return ''

		route	= "#{ if from then from else '' }#{ if to then ' > ' + to else '' }"
		route	+= ' ' if route

		content	= words.join ' '

		result = "#{ route }'#{ cmd or '' }' #{ content }"

		return result
}

terminal = {
	input: {
		submit: (text) ->
			return false if not text

			$$.terminal_input.attr 'value', ''

			if text = terminal.input.parse text
				terminal.input.send text

		parse: (text) ->
			if not text
				return error 'Invalid syntax.'

			if not text[0].match cfg.cmdChars
				return error 'Invalid syntax. Unrecognized command character'

			words = text.split ' '

			words[0] = words[0].toLowerCase()

			text = words.join ' '

			return text

		send: (text) ->
			return false if not server.conn

			server.conn.emit 'input', text

			console.log 'Emitted: input,', text

		listeners: {
			keypress: (event) ->
				if event.which is 13
					terminal.input.submit this.value
					return false

			focus: ->
				$$.terminal_caret.toggleClass 'active'

			focusout: ->
				$$.terminal_caret.removeClass 'active'

		}

	}

	add: (tabName, text = '') ->
		return false if tabName not of terminal.tabMap

		tab = terminal.tabMap[tabName]

		++tab.lines

		now = new Date()
		nowFormatted = now.getMonth() + '.' + now.getDate() + ' ' + now.getHours() + ':' + now.getMinutes()
		timestamp = "<span class='timestamp' data='#{ now.getTime() }'>#{ nowFormatted }</span>"

		tab.content.append "<li value='#{ tab.lines }'>#{ text }</li>\n"

		if tab.content.hasClass 'active'
			terminal.scrollbar.update $$.content
			terminal.scrollbar.scroll $$.content, 'bottom'

	addInput: (text = '') ->
		identifier = "<span class=\"caret\">&gt;&gt;</span>"

		for key of terminal.tabMap
			terminal.add key, identifier + text

		return true

	tabMap: {}

	buildTabs: ->
		buttons				= $$.tab_buttons
		contentContainer	= $$.content

		terminal.tabMap = {}

		buttons.each () ->
			button	= $(this)
			name	= button.attr 'name'
			content	= $(".tab-content[name=\"#{ name }\"]", contentContainer)

			terminal.tabMap[name] = {
				button
				content
				lines: 0
			}

			button.click () ->
				terminal.switchTab $(this)

		return true

	switchTab: (selector) ->
		return false if selector.hasClass 'active'

		name = selector.attr 'name'

		tab = terminal.tabMap[name]

		$$.tab_buttons.each -> $(this).removeClass 'active'
		$$.tab_contents.each -> $(this).removeClass 'active'

		tab.button.addClass 'active'
		tab.content.addClass 'active'

		terminal.scrollbar.update $$.content
		terminal.scrollbar.scroll $$.content, 'bottom'

	scrollbar: {
		scroll: (selector, pos) ->
			selector.mCustomScrollbar 'scrollTo', pos

		update: (selector) ->
			selector.mCustomScrollbar 'update'
	}
}

# helpers

bind = (listeners, bindee, funcName = 'on') ->
	for key, fn of listeners
		bindee[funcName] key, fn

	return bindee

error = (str = '') ->
	console.log 'Error:', str
	return false

# scrollbar shortcut functions




###

# Tab switching
for key, tab of tabs
	tab.selector.click(->
		self	= $(this)
		tabName	= self.attr('name')

		return false if self.hasClass('active') or ! tabName of tabs

		selections.tabs.buttons.removeClass('active')
		selections.tabs.content.removeClass('active')

		self.addClass('active')

		tabs[tabName].content.selector.addClass('active')

		scrollbar.update(selections.content)
	)


format = {
	msg : (text) ->
		text = text + '\r\n'

		msg = {
			text		: text
			origin		: ''
			destination	: 'server'
			command		: ''
			words		: []
		}

		words = text.split(' ')

		if ! words[0].match(/^:/)
			words.unshift(':webClient')

		if words[0].match(/^:/)
			msg.origin		= words[0].replace(/^:/, '')
			words			= words[1..]

		msg.command		= words[0] || ''
		words			= words[1..]

		msg.words = words

		return msg
}

message = {
	add : (tabName, text) ->
		return false if ! tabName of tabs

		tab = tabs[tabName]

		tab.content.lines = content.lines or 0
		++tab.content.lines

		line = tab.content.lines

		tab.content.selector.append("<li value='#{line}'>#{text}</li>\n")

		scrollbar.update(selections.content)
		scrollbar.bottom(selections.content)

		return true

	send : (text) ->
		return false if ! text or typeof text isnt 'string'

		console.log('Sending: ', text)

		server.emit('input', text)
}

commands = [
	[
		/msg/i
		(msg) ->
			origin		= msg.origin
			destination	= msg.words[0]
			words		= msg.words[1..].join(' ')
			command		= 'WEB:BOTMSG'

			if destination.match(/^[#&]/)
				command = 'WEB:PRIVMSG'

			ary = [
				':' + origin
				command
				destination
				':' + words
			]

			return ary.join(' ')
	]
]

handle = {
	eventStruct : (msg, eventStruct) ->
		for args in eventStruct
			match		= args[0]
			callback	= args[1]

			if ( match instanceof RegExp and msg.command.match(match) ) or msg.command is match
				return callback(msg)

		return false

	msg : (data) ->
		msg		= format.msg(data)
		text	= handle.eventStruct(msg, commands)

		message.send(text)
}




###






