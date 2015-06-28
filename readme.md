```
       __          
      / /__________
     / / / ___/___/
    / / / / / /__  
   /_/_/_/  \___/  
                   
```
Lirc is an irc client for bots.

### Status: *UNMAINTAINED*
If you have interest in the project please let me know, I may consider a full recode with updated libraries 

Features:

- Built-in **botnet** functionality via the cluster module
- Instead of telnet, use a **web interface** to administrate bots
- Extendable via mappings and event minipulation
- Automatically join secure irc networks without manually managing certificates

```coffee
lirc = require 'lirc'

# set up the bots config
lirc {
    server: { # can be an array of server objects
        host    : 'irc.freenode.net'
        port    : 6667
        secure  : false # if true, will generate a certificate and connect over TLS
        user: {
            nick    : 'Botty'
            altnick : 'Botty??' # ? question marks are substituted with random numbers
            username: 'Botty'
        }
    }
}

# connect to the topmost network if multiple are specified
lirc.connect()

# will be emitted once rpl_welcome is emitted
lirc.on 'connected', -> 
    lirc.join '#test5000'

# emitted for all irc events
lirc.on 'raw', (data) ->
    console.log "raw: #{data}"

# emitted when a privmsg comes from channel #test5000
lirc.on '#test5000', (msg) ->

# emitted when you get a message from a user
lirc.on 'usermsg', (msg) ->
    msg.reply msg.text # echo back messages from users

# emitted on irc event rpl_welcome
lirc.on 'rpl_welcome', (msg) ->
    # you're connected to the network at this point

# emitted manually by another bot, captured here
# the asterisk * character for any Lirc event emitter is emitted for every single event
lirc.botnet.on '*', (msg) -> 
    console.log 'botnet', msg

```

All event names are case-insensitive, in that they're converted to lower case before being emitted or listened for.

Error handling for Lirc catches all errors. If it's an error on the cluster master, the whole thing will be killed and the error logged. If it's an error on a worker (a bot), then the bot is restarted after a short delay and the error is logged to a file. 

Such errors can be read from the web interface by either reading the error.log file directly or by watching output from each bot.

### Web interface
screenshot_to_be_taken_and_put_here

### State of development
A few features are not stable, incomplete or not yet implimented.

- The web interface could use input commands for IRC interactivity, such as joining channels etc. This I believe I may expand into a full IRC client app, with a sidebar channel/dialog tree for each connected bot. Saving configuration, joined channels, keys etc. may pose a design structure issue in that each bot would require an eggdrop-esque .chan file, for meta info like that for persistance between restarts.
- IRC Protocol filtering, formatting etc. could be fleshed out. Most of the main IRC codes/commands are delt with, but they could be parsed more thoroughly. To elaborate, it's mostly down to parsing the raw IRC string into usable parts and also creating documentation for what perameters are avaliable from each IRC command.
- Cross-server botnets haven't been tested/worked out.
- Passwording and cookie sessions for the web interface not yet implimented. I intend to simply store an ciphered cookie containing a nickname for the user (to identify between administrators) and a global password for all admins defined in the config. This would also allow for joining IRC networks without assuming the role of a currently running bot.
- SSL/secure connection certs should be re-used and regenerated when expired. At the moment they're generated for each new secure connection.
- I will impliment an *n* restarts or die rule for bots, though the web interface should remain up even if all of the running bots error out, thus allowing you to check the error log and fix your code.

Lirc is built on top of Lance.

### Thanks
Feel free to use any code for your own projects or contribute to this repo.
