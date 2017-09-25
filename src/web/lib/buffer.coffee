
web = require './web'

web.buffer = {
	buffer: []

	add: (arg) ->
		@buffer.push arg

		if ( length = @buffer.length ) >= 1000
			@buffer = @buffer[100..length]
}

