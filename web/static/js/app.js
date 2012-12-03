(function() {
  var cache, cfg, commands, format, handle, key, message, scrollbar, selections, server, tab, tabs;

  cache = {
    commands: [],
    tabs: {
      lineCounts: {
        all: 0,
        irc: 0,
        botnet: 0
      }
    }
  };

  server = void 0;

  tabs = {
    all: {
      selector: $('.tabs .tab[name=all]'),
      content: {
        selector: $('.content .tab-content[name=all]'),
        lines: 0
      }
    },
    irc: {
      selector: $('.tabs .tab[name=irc]'),
      content: {
        selector: $('.content .tab-content[name=irc]'),
        lines: 0
      }
    },
    botnet: {
      selector: $('.tabs .tab[name=botnet]'),
      content: {
        selector: $('.content .tab-content[name=botnet]'),
        lines: 0
      }
    }
  };

  selections = {
    tabs: {
      buttons: $('.tabs .tab'),
      content: $('.content .tab-content')
    },
    content: $('.content'),
    terminal: {
      input: $('.terminal .input input'),
      caret: $('.terminal .input .caret')
    }
  };

  cfg = {
    scrollbar: {
      scrollInertia: 0
    }
  };

  scrollbar = {
    bottom: function(selector) {
      return selector.mCustomScrollbar('scrollTo', 'bottom');
    },
    to: function(selector, pos) {
      return selector.mCustomScrollbar('scrollTo', pos);
    },
    update: function(selector) {
      return selector.mCustomScrollbar('update');
    }
  };

  message = {
    add: function(tabName, text) {
      var line, tab;
      if (!tabName in tabs) {
        return false;
      }
      tab = tabs[tabName];
      tab.content.lines = content.lines || 0;
      ++tab.content.lines;
      line = tab.content.lines;
      tab.content.selector.append("<li value='" + line + "'>" + text + "</li>\n");
      scrollbar.update(selections.content);
      scrollbar.bottom(selections.content);
      return true;
    },
    send: function(text) {
      if (!text || typeof text !== 'string') {
        return false;
      }
      console.log('Sending: ', text);
      return server.emit('data', text);
    }
  };

  commands = [
    [
      /msg/i, function(msg) {
        var ary, command, destination, origin, words;
        origin = msg.origin;
        destination = msg.words[0];
        words = msg.words.slice(1).join(' ');
        command = 'WEB:BOTMSG';
        if (destination.match(/^[#&]/)) {
          command = 'WEB:PRIVMSG';
        }
        ary = [':' + origin, command, destination, ':' + words];
        return ary.join(' ');
      }
    ]
  ];

  handle = {
    eventStruct: function(msg, eventStruct) {
      var args, callback, match, _i, _len;
      for (_i = 0, _len = eventStruct.length; _i < _len; _i++) {
        args = eventStruct[_i];
        match = args[0];
        callback = args[1];
        if ((match instanceof RegExp && msg.command.match(match)) || msg.command === match) {
          return callback(msg);
        }
      }
      return false;
    },
    msg: function(data) {
      var msg, text;
      msg = format.msg(data);
      text = handle.eventStruct(msg, commands);
      return message.send(text);
    }
  };

  format = {
    msg: function(text) {
      var msg, words;
      text = text + '\r\n';
      msg = {
        text: text,
        origin: '',
        destination: 'server',
        command: '',
        words: []
      };
      words = text.split(' ');
      if (!words[0].match(/^:/)) {
        words.unshift(':webClient');
      }
      if (words[0].match(/^:/)) {
        msg.origin = words[0].replace(/^:/, '');
        words = words.slice(1);
      }
      msg.command = words[0] || '';
      words = words.slice(1);
      msg.words = words;
      return msg;
    }
  };

  for (key in tabs) {
    tab = tabs[key];
    tab.selector.click(function() {
      var self, tabName;
      self = $(this);
      tabName = self.attr('name');
      if (self.hasClass('active') || !tabName in tabs) {
        return false;
      }
      selections.tabs.buttons.removeClass('active');
      selections.tabs.content.removeClass('active');
      self.addClass('active');
      tabs[tabName].content.selector.addClass('active');
      return scrollbar.update(selections.content);
    });
  }

  selections.terminal.input.focus(function() {
    return selections.terminal.caret.toggleClass('active');
  });

  selections.terminal.input.focusout(function() {
    return selections.terminal.caret.removeClass('active');
  });

  $(document).ready(function() {
    selections.content.mCustomScrollbar(cfg.scrollbar);
    scrollbar.bottom(selections.content);
    server = io.connect('http://localhost:5080');
    server.on('data', function(msg) {
      console.log('Recieved: ', msg);
      return message.add('all', msg.text);
    });
    return selections.terminal.input.keypress(function(event) {
      var content;
      if (event.which === 13) {
        content = this.value;
        console.log(content);
        if (!content) {
          return false;
        }
        $(this).attr('value', '');
        console.log('emitting');
        handle.msg(content);
        return false;
      }
    });
  });

}).call(this);
