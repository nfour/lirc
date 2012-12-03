
path = require 'path'

module.exports = {
	root: path.dirname __dirname

	templating: {
		ect: {
			engine	: require 'ect'
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