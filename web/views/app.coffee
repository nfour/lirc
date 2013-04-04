
# requires jquery >= 1.7.0

$html = undefined

cfg = {
	scrollbar: {
		scrollInertia: 0
	}

	server: { # could also be a url. may be best to do this
		port: 1339
		host: '10.0.0.7'
	}

	cmdChars: /[\.\+\-]/i

}

$(document).ready ->
	# create selectors
	$html = {
		terminal	: $('.terminal-outer')
		tab			: $('.terminal-tabs > .tab')
		bot_tab		: $('.bot-tabs > .tab')
		bot_content	: $('.bot-content')
	}

	for key, val in $html
		$html[key] = $('<div>').append( val.clone() ).html()

	server.conn = conn = io.connect "http://#{ cfg.server.host }:#{ cfg.server.port }"

	# bind listeners to the server
	bind server.listeners, conn

	terminal.input.send '.buffer'

# scope variables

server = {
	conn: undefined

	listeners: {
		msg: (bot, msg) ->
			return false if not server.checkInput arguments

			return false if not args = parseMsg msg

			if args.important
				terminal.add bot, ['all', 'irc', 'irc_verbose'], args
			else
				terminal.add bot, 'irc_verbose', args

			args.col3 = msg.raw

			terminal.add bot, 'irc_raw', args

		botnet: (bot, obj, fromBot = bot) ->
			console.log arguments
			msg = {
				cmd: fromBot
				text: "#{obj.cmd}: #{obj.args.join ' '}"
				time: obj.time
			}

			return false if not args = parseMsg msg, { nbsp: false }

			args.col2Class = 'botnet'

			terminal.add bot, ['all', 'botnet'], args

		lirc: (obj) ->
			msg = {
				cmd: "Lirc"
				text: obj.text
				time: obj.time
			}

			return false if not args = parseMsg msg

			args.col2Class = 'lirc'

			terminal.addAll '*', args

		botinfo: (names) ->
			terminal.buildTerminal names

		buffer: (buffer) ->
			console.log 'Injecting buffer...'

			for args in buffer
				eventName = args[0]

				switch eventName
					when 'buffer', 'botinfo', 'input'
						continue

				if eventName of server.listeners
					server.listeners[ eventName ].apply server.listeners, args[1..]
	}

	checkInput: (args) ->
		if args[0] not of terminal.botMap
			console.log args
			return console.error "[WARN] '#{args[0]}' not in botMap"

		return true
}

parseMsg = (msg, opt = { nbsp: true }) ->
	r = {
		col1: ''
		col2: msg.cmd or ''
		col3: ''
	}

	msg.text	?= ''
	msg.raw		?= msg.text

	return false if not msg.text

	if opt.nbsp
		msg.raw		= msg.raw.replace /\ /g, '&nbsp;' if msg.raw
		msg.text	= msg.text.replace /\ /g, '&nbsp;' if msg.text

	r.col3 = msg.text

	[time, r.col1] = parseMsg.time new Date( msg.time or null )

	r.col1Data = time.getTime()

	if msg.cmd.match ///^(
		PRIVMSG|NOTICE|JOIN|PART|SEND|QUIT
	)$///i
		r.important = true
		r.col2Class = msg.cmd.toLowerCase()

		if msg.cmd is 'PRIVMSG'
			if msg.target.match /^[\#\&]/
				r.col2Class	= 'chanmsg'
				r.col2		= msg.target or msg.cmd
				r.col3		= "&lt;#{msg.mask.nick}&gt; #{r.col3}"
			else
				r.col2Class = 'usermsg'
				r.col2		= msg.target or msg.cmd
				r.col3		= "&lt;#{msg.mask.nick}&gt; #{r.col3}"

		if msg.cmd is 'SEND' and msg.text.match /^PONG/
			r.important = false

		if msg.cmd is 'JOIN'
			r.col3 = "#{msg.mask.nick} joined #{msg.chan}"
			r.important = false

		if msg.cmd is 'PART'
			r.col3 = "#{msg.mask.nick} left #{msg.chan}"
			r.important = false

		if msg.cmd is 'QUIT'
			r.col3 = "#{msg.mask.raw} quit"
			r.important = false

	if r.col2.length > 11
		r.col2Title	= r.col2
		r.col2		= "#{r.col2[0..8]}..."

	return r

parseMsg.time = (time = new Date()) ->
	seconds	= time.getSeconds()
	hours	= time.getHours()
	mins	= time.getMinutes()

	if seconds < 10		then seconds	= '0' + seconds
	if hours < 10		then hours		= '0' + hours
	if mins < 10		then mins		= '0' + mins

	ms = time.getTime()

	return [time, "#{hours}:#{mins}.#{seconds}"]

terminal = {
	input: {
		submit: (text) ->
			return false if not text

			$('.terminal .input input').attr 'value', ''

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
				$(this).siblings('.caret').toggleClass 'active'

			focusout: ->
				$(this).siblings('.caret').removeClass 'active'

		}

	}

	add: (bot, tabs, args) ->
		if typeof tabs is 'string'
			if tabs is '*'
				tabs = []
				for key of @botMap
					for tabName of @botMap[key].tabs
						tabs.push tabName
					break
			else
				tabs = [tabs]

		for tabName in tabs
			continue if tabName not of @botMap[bot]?.tabs

			tab = @botMap[bot].tabs[tabName]

			tab.content.append """
				<div class='row'>
					<div class='cell col1 #{args.col1Class or ''}' data='#{args.col1Data or ''}'>#{args.col1}</div>
					<div class='cell col2 #{args.col2Class or ''}' title='#{args.col2Title or ''}'>#{args.col2}</div>
					<div class='cell col3 #{args.col3Class or ''}'>#{args.col3}</div>
				</div>\n
			"""
			++tab.lines

			if tab.content.hasClass 'active'
				terminal.scrollbar.update bot
				terminal.scrollbar.scroll bot, 'bottom'

	addAll: (tabs, args) ->
		for bot of @botMap
			@add bot, tabs, args

	botMap: {}

	buildTabs: (bot, container) ->
		buttons = $(".terminal-tabs .tab", container)

		tabs = {}

		buttons.each () ->
			button	= $(this)
			name	= button.attr 'name'
			content	= $(".content .tab-content[name=\"#{ name }\"]", container)

			tabs[name] = {
				button
				content
				lines: 0
			}

			button.click () ->
				do -> terminal.switchTab bot, button

		return tabs

	buildTerminal: (names) ->
		for name in names
			map = {}

			# button
			if existing = $('.bot-tabs .tab:not([name])')[0] or $(".bot-tabs .tab[name=#{name}]")[0]
				map.button = $(existing)
					.attr( 'name', name )
					.html( name )
			else
				container = $('.bot-tabs')

				button = $('<div class="tab">')
					.attr( 'name', name )
					.html( name )

				map.button = $( button.appendTo container )

			map.button.click () ->
				terminal.switchBotTab $(this)

			# content
			if existing = $('.bot-content:not([name])')[0] or $(".bot-content[name=#{name}]")[0]
				map.content = $(existing)
					.attr( 'name', name )
			else
				container = $('.terminal-outer')

				content = $('<div class="bot-content">')
					.attr( 'name', name )
					.html( $html.bot_content.html() )

				map.content = $( content.appendTo container )

			#if not map.content.find '.mCustomScrollbar'

			# content tabs
			map.tabs = terminal.buildTabs name, map.content

			terminal.botMap[name] = map

		terminal.scrollbar.build $('.content')

		bind terminal.input.listeners, $('.terminal .input input')

		return terminal.botMap

	switchBotTab: (selector) ->
		return false if selector.hasClass 'active'

		bot = selector.attr 'name'

		tab = terminal.botMap[bot]

		$('.bot-tabs .tab').each -> $(this).removeClass 'active'
		$('.bot-content').each -> $(this).removeClass 'active'

		tab.button.addClass 'active'
		tab.content.addClass 'active'

		terminal.scrollbar.update bot
		terminal.scrollbar.scroll bot, 'bottom'

	switchTab: (bot, selector) -> # MAKE THIS WORK ############ then make add() etc work
		name = selector.attr 'name'
		return false if selector.hasClass('active') or not name

		tab			= terminal.botMap[bot].tabs[name]
		container	= terminal.botMap[bot].content

		$('.terminal-tabs .tab', container).each -> $(this).removeClass 'active'
		$('.tab-content', container).each -> $(this).removeClass 'active'

		tab.button.addClass 'active'
		tab.content.addClass 'active'

		terminal.scrollbar.update bot
		terminal.scrollbar.scroll bot, 'bottom'

	scrollbar: {
		scroll: (bot, pos = 'bottom') ->
			if bot
				$(".bot-content[name=#{bot}] .mCustomScrollbar").mCustomScrollbar 'scrollTo', pos
			else
				$(".mCustomScrollbar").each -> $(this).mCustomScrollbar 'scrollTo', pos

		update: (bot) ->
			if bot
				$(".bot-content[name=#{bot}] .mCustomScrollbar").mCustomScrollbar 'update'
			else
				$(".mCustomScrollbar").each -> $(this).mCustomScrollbar 'update'

		build: ($obj) ->
			$obj.mCustomScrollbar cfg.scrollbar
	}
}

# helpers

bind = (listeners, bindee, funcName = 'on') ->
	for key, fn of listeners
		bindee[funcName] key, fn

	return bindee


