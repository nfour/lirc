(function() {var $$, bind, cfg, error, server, terminal;$$ = void 0;cfg = {scrollbar: {scrollInertia: 0},server: {port: 8765,host: 'localhost'},cmdChars: /[\.\+\-]/i};$(document).ready(function() {var conn;$$ = {terminal: $('.terminal'),terminal_caret: $('.terminal .caret'),terminal_input: $('.terminal .input input'),tabs: $('.tabs'),tab_buttons: $('.tabs .tab'),tab_contents: $('.content .tab-content'),content: $('.content')};$$.content.mCustomScrollbar(cfg.scrollbar);terminal.scrollbar.scroll($$.content, 'bottom');server.conn = conn = io.connect("http://" + cfg.server.host + ":" + cfg.server.port);bind(server.listeners, conn);bind(terminal.input.listeners, $$.terminal_input);return terminal.buildTabs();});server = {conn: void 0,listeners: {msg: function(msg) {console.log('Recieved msg:', msg);terminal.add('all', server.prettyMsg(msg));if (msg.cmd.match(/^(BOTMSG|WEBMSG)$/i)) {return terminal.add('botnet', server.prettyMsg(msg));} else {return terminal.add('irc', server.prettyMsg(msg));}},data: function(data) {console.log('Recieved data:', data);return terminal.add('raw_irc', data);},input: function(data) {console.log('Recieved data:', data);return terminal.addInput(data);},send: function(data) {return terminal.addInput('SEND ' + data);},botmsg: function(data) {console.log('Recieved data:', data);return terminal.add('botnet', data);}},prettyMsg: function(msg) {var cmd, content, from, result, route, to, words;from = msg.from, to = msg.to, cmd = msg.cmd, words = msg.words;if (!(from || to || cmd || words.join(''))) {return '';}route = "" + (from ? from : '') + (to ? ' > ' + to : '');if (route) {route += ' ';}content = words.join(' ');result = "" + route + "'" + (cmd || '') + "' " + content;return result;}};terminal = {input: {submit: function(text) {if (!text) {return false;}$$.terminal_input.attr('value', '');if (text = terminal.input.parse(text)) {return terminal.input.send(text);}},parse: function(text) {var words;if (!text) {return error('Invalid syntax.');}if (!text[0].match(cfg.cmdChars)) {return error('Invalid syntax. Unrecognized command character');}words = text.split(' ');words[0] = words[0].toLowerCase();text = words.join(' ');return text;},send: function(text) {if (!server.conn) {return false;}server.conn.emit('input', text);return console.log('Emitted: input,', text);},listeners: {keypress: function(event) {if (event.which === 13) {terminal.input.submit(this.value);return false;}},focus: function() {return $$.terminal_caret.toggleClass('active');},focusout: function() {return $$.terminal_caret.removeClass('active');}}},add: function(tabName, text) {var now, nowFormatted, tab, timestamp;if (text == null) {text = '';}if (!(tabName in terminal.tabMap)) {return false;}tab = terminal.tabMap[tabName];++tab.lines;now = new Date();nowFormatted = now.getMonth() + '.' + now.getDate() + ' ' + now.getHours() + ':' + now.getMinutes();timestamp = "<span class='timestamp' data='" + (now.getTime()) + "'>" + nowFormatted + "</span>";tab.content.append("<li value='" + tab.lines + "'>" + text + "</li>\n");if (tab.content.hasClass('active')) {terminal.scrollbar.update($$.content);return terminal.scrollbar.scroll($$.content, 'bottom');}},addInput: function(text) {var identifier, key;if (text == null) {text = '';}identifier = "<span class=\"caret\">&gt;&gt;</span>";for (key in terminal.tabMap) {terminal.add(key, identifier + text);}return true;},tabMap: {},buildTabs: function() {var buttons, contentContainer;buttons = $$.tab_buttons;contentContainer = $$.content;terminal.tabMap = {};buttons.each(function() {var button, content, name;button = $(this);name = button.attr('name');content = $(".tab-content[name=\"" + name + "\"]", contentContainer);terminal.tabMap[name] = {button: button,content: content,lines: 0};return button.click(function() {return terminal.switchTab($(this));});});return true;},switchTab: function(selector) {var name, tab;if (selector.hasClass('active')) {return false;}name = selector.attr('name');tab = terminal.tabMap[name];$$.tab_buttons.each(function() {return $(this).removeClass('active');});$$.tab_contents.each(function() {return $(this).removeClass('active');});tab.button.addClass('active');tab.content.addClass('active');terminal.scrollbar.update($$.content);return terminal.scrollbar.scroll($$.content, 'bottom');},scrollbar: {scroll: function(selector, pos) {return selector.mCustomScrollbar('scrollTo', pos);},update: function(selector) {return selector.mCustomScrollbar('update');}}};bind = function(listeners, bindee, funcName) {var fn, key;if (funcName == null) {funcName = 'on';}for (key in listeners) {fn = listeners[key];bindee[funcName](key, fn);}return bindee;};error = function(str) {if (str == null) {str = '';}console.log('Error:', str);return false;};/*# Tab switchingfor key, tab of tabstab.selector.click(->self	= $(this)tabName	= self.attr('name')return false if self.hasClass('active') or ! tabName of tabsselections.tabs.buttons.removeClass('active')selections.tabs.content.removeClass('active')self.addClass('active')tabs[tabName].content.selector.addClass('active')scrollbar.update(selections.content))format = {msg : (text) ->text = text + '\r\n'msg = {text		: textorigin		: ''destination	: 'server'command		: ''words		: []}words = text.split(' ')if ! words[0].match(/^:/)words.unshift(':webClient')if words[0].match(/^:/)msg.origin		= words[0].replace(/^:/, '')words			= words[1..]msg.command		= words[0] || ''words			= words[1..]msg.words = wordsreturn msg}message = {add : (tabName, text) ->return false if ! tabName of tabstab = tabs[tabName]tab.content.lines = content.lines or 0++tab.content.linesline = tab.content.linestab.content.selector.append("<li value='#{line}'>#{text}</li>\n")scrollbar.update(selections.content)scrollbar.bottom(selections.content)return truesend : (text) ->return false if ! text or typeof text isnt 'string'console.log('Sending: ', text)server.emit('input', text)}commands = [[/msg/i(msg) ->origin		= msg.origindestination	= msg.words[0]words		= msg.words[1..].join(' ')command		= 'WEB:BOTMSG'if destination.match(/^[#&]/)command = 'WEB:PRIVMSG'ary = [':' + origincommanddestination':' + words]return ary.join(' ')]]handle = {eventStruct : (msg, eventStruct) ->for args in eventStructmatch		= args[0]callback	= args[1]if ( match instanceof RegExp and msg.command.match(match) ) or msg.command is matchreturn callback(msg)return falsemsg : (data) ->msg		= format.msg(data)text	= handle.eventStruct(msg, commands)message.send(text)}*/}).call(this);