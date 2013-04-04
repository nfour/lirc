
path = require 'path'

module.exports = {
	ascii: false
	root: path.dirname __dirname

	templating: {
		ect: {
			ext		: '.ect'
			findIn	: 'views'
			minify	: false

			options: {
				cache	: true
				watch	: true
				open	: '<<'
				close	: '>>'
			}
		}

		stylus: {
			minify		: true
			findIn		: 'views'
			renderTo	: 'static'
		}

		coffee: {
			minify		: true
			findIn		: 'views'
			renderTo	: 'static'
		}
	}
}