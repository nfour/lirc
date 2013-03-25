# lirc
lirc is an IRC client, for bots.

## Why use it?
lirc has more to it than other node.js irc client libraries.

- Built in **botnet** functionality via the cluster module
- Instead of telnet, use a **web interface**, accessable anywhere, to manage and view bots
- Extendable via mappings and event minipulation
- Automatically join SSL networks without manually managing certificates

## State of development
A few features are not stable, incomplete or non-existant.

- Error handling/consistancy needs solid work.

- The web interface needs input commands, for joining channels/minipulating bots etc. Additionally, the ability to join
a dialog/channel will be added, essentially making the web interface into a user friendly IRC client. It would either
assume the presence of an existing bot or create a new "bot" under a user specified nickname, network, etc.

- IRC Protocol filtering, formatting etc. needs to be fleshed out. Most of the main IRC codes/commands are delt with, but 
they could be parsed more thoroughly.

- Cross-server botnets haven't been tested/worked out.

- Passwording and cookie sessions for the web interface not yet implimented.

- Hostname bindings not yet explored.

- SSL/secure connection certs should be re-used and regenerated when expired. At the moment they're generated on each connection.
