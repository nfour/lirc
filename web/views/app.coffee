
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

# scope variables

server = {
	conn: undefined

	listeners: {
		msg: (bot, msg) ->
			return false if not server.checkInput arguments

			terminal.add bot, 'all', server.prettyMsg msg

			if msg.cmd is 'BOTMSG'
				terminal.add bot, 'botnet', server.prettyMsg msg
			else
				terminal.add bot, 'irc', server.prettyMsg msg

		data: (bot, data) ->
			return false if not server.checkInput arguments

			terminal.add bot, 'raw_irc', data

		input: (bot, data) ->
			return false if not server.checkInput arguments

			terminal.addInput bot, data

		send: (bot, data) ->
			return false if not server.checkInput arguments

			terminal.addInput bot, 'SEND ' + data # need to change addInput to addAll or something

		botmsg: (bot, data) ->
			return false if not server.checkInput arguments

			console.log 'Recieved data:', arguments

			terminal.add bot, 'botnet', data

		botinfo: (bot, names) ->
			terminal.buildTerminal names
	}

	prettyMsg: (msg) ->
		ary = []

		ary.push "[ #{msg.cmd} ]"

		for key, val of msg
			if key.match /^(raw|words|cmd|remains|origin)$/ then continue
			if key is 'target22'
				continue if not val or val is lirc.session.server.user.nick
			ary.push "#{key}=\"#{val}\""

		result = ary.join ', '

		result = result.replace /\ /g, '&nbsp;'

		return result

	checkInput: (args) ->
		if args[0] not of terminal.botMap
			return console.error "[WARN] '#{args[0}' not in botMap"

		return true
}

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

	add: (bot, tabName, text = '') ->
		return false if tabName not of terminal.botMap[bot].tabs

		tab = terminal.botMap[bot].tabs[tabName]

		now = new Date()
		nowFormatted = now.getMonth() + '.' + now.getDate() + ' ' + now.getHours() + ':' + now.getMinutes()
		timestamp = "<span class='timestamp' data='#{ now.getTime() }'>#{ nowFormatted }</span>"

		tab.content.append "<li value='#{ tab.lines }'>#{ timestamp + text }</li>\n"
		++tab.lines

		if tab.content.hasClass 'active'
			terminal.scrollbar.update bot
			terminal.scrollbar.scroll bot, 'bottom'

	addInput: (bot, text = '') ->
		identifier = "<span class=\"caret\">&gt;&gt;</span>"

		for tabName of terminal.botMap[bot].tabs
			terminal.add bot, tabName, identifier + text

		return true

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

		console.log terminal.botMap

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
		console.log 'name', name
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


error = (str = '') ->
	console.log 'Error:', str
	return false

