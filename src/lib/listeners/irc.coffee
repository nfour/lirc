
lirc	= require '../lirc'
cluster	= require 'cluster'

module.exports = {
	data: (data) ->
		lirc.parse.raw data
		lirc.emit 'raw', data

	connect: () ->
		console.log 'Net socket connected'

		lirc.emit 'connect'

	secureConnection: () ->
		console.log 'TLS socket connected'

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
