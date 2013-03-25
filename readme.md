# lirc
lirc is an IRC client, for bots.

## Why use lirc?
Well, lirc has more to it than other node.js irc client libraries.

- Built-in **botnet** functionality via the cluster module
- Instead of telnet we use a **web interface**, accessable anywhere, to manage and view bots
- Extendable via mappings and event minipulation
- Automatically join secure irc networks without manually managing certificates

## Examples
```coffee
	lirc = require 'lirc'

	# set up the bots config
	lirc {
		me: 'Botty' # if not specified, will default to server.user.username
		server: {
			host: 'irc.freenode.com'
			port: 7000
			user: {
				nick: 'Botty??' # ?? question marks are substituted with random numbers
				username: 'Botty'
			}

			secure: false
		}
	}

	# connect to the topmost network if multiple are specified
	lirc.connect()

	# will be emitted once rpl_welcome is emitted
	lirc.on 'connected', () ->
		lirc.join '#test5000'

	# emitted for all irc events
	lirc.on 'raw', (data) ->
		console.log "[RAW] #{data}"

	# emitted when a privmsg comes from channel #test5000
	lirc.on '#test5000', (msg) ->

	# emitted when you get a message from a user
	lirc.on 'usermsg', (msg) ->

	# emitted on irc event rpl_welcome
	lirc.on 'rpl_welcome', (msg) ->

	# emitted manually be another bot, captured here
	lirc.botnet.on 'hello', (from) ->
		console.log '#{from} says hello.'
```

All event names are case-insensitive.

## Web interface
screenshot_to_be_taken_and_put_here

## State of development
A few features are not stable, incomplete or non-existant.

- Error handling/consistancy needs solid work.
- The web interface needs input commands, for joining channels/minipulating bots etc. Additionally, the ability to join a dialog/channel will be added, essentially making the web interface into a user friendly IRC client. It would either assume the presence of an existing bot or create a new "bot" under a user specified nickname, network, etc.
- IRC Protocol filtering, formatting etc. needs to be fleshed out. Most of the main IRC codes/commands are delt with, but they could be parsed more thoroughly.
- Cross-server botnets haven't been tested/worked out.
- Passwording and cookie sessions for the web interface not yet implimented.
- Hostname bindings not yet explored.
- SSL/secure connection certs should be re-used and regenerated when expired. At the moment they're generated for each new connection.
- Optimizations to web interface necessary. Merging of static assets etc.

lirc is built on top of Lance, a minimal framework. Hence the name, Lance-irc.
Lance should be avaliable on npm when this is stable.

## Thanks
Feel free to use any code for your own projects or contribute to this repo.
