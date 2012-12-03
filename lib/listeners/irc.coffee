
lirc = require '../lirc'
cluster = require 'cluster'

module.exports = {
	data: (data) ->
		lirc.emit 'data', data
		lirc.botnet.send.master 'emit::master', ['data', data]
		lirc.parse.data data

	connect: () ->
		console.log 'Socket, Connect'

		lirc.auth()

		lirc.emit 'connect'
	
	error: (err) ->
		console.log 'Socket, Error: ', err
		lirc.emit 'error', err

	close: (hadError) ->
		console.log 'Socket, close: hadError = ', hadError
		lirc.emit 'close', hadError

	timeout: () ->
		console.log 'Socket, Timeout'
		lirc.emit 'timeout'

	end: () ->
		console.log 'Socket, End'
		lirc.emit 'end'

}
