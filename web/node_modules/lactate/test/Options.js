
var Lactate = require('../lib/lactate')
var should = require('should')

describe('Constructor', function() {

    describe('#Lactate({"root", "public", "cache", "expires"})', function() {

        var lactate = Lactate.Lactate({
            'root':'files',
            'public':'files',
            'cache':false,
            'expires':'one hour'
        })

        it('Should have root option "files"', function() {
            var opt = lactate.get('root')
            opt.should.equal('files')
        })

        it('Should have public option "files"', function() {
            var opt = lactate.get('public')
            opt.should.equal('files')
        })

        it('Should have cache option false', function() {
            var opt = lactate.get('cache')
            opt.should.equal(false)
        })

        it('Should have expires option 3600', function() {
            var opt = lactate.get('expires')
            opt.should.equal(3600)
        })

    })

})

describe('Set Object', function() {


    describe('#set({"root", "public", "cache", "expires"})', function() {

        var lactate = Lactate.Lactate()
        lactate.set({
            'root':'files',
            'public':'files',
            'cache':false,
            'expires':'one hour'
        })

        it('Should have root option "files"', function() {
            var opt = lactate.get('root')
            opt.should.equal('files')
        })

        it('Should have public option "files"', function() {
            var opt = lactate.get('public')
            opt.should.equal('files')
        })

        it('Should have cache option false', function() {
            var opt = lactate.get('cache')
            opt.should.equal(false)
        })

        it('Should have expires option 3600', function() {
            var opt = lactate.get('expires')
            opt.should.equal(3600)
        })

    })

})

describe('Set K/V', function() {

    describe('#set("root", "files")', function() {
        it('Should have root option "files"', function() {
            var lactate = Lactate.Lactate()
            lactate.set('root', 'files')
            var opt = lactate.get('root')
            opt.should.equal('files')
        })
    })

    describe('#set("public", "files")', function() {
        it('Should have public option "files"', function() {
            var lactate = Lactate.Lactate()
            lactate.set('public', 'files')
            var opt = lactate.get('public')
            opt.should.equal('files')
        })
    })

    describe('#set("cache", false)', function() {
        it('Should have cache option false', function() {
            var lactate = Lactate.Lactate()
            lactate.set('cache', false)
            var opt = lactate.get('cache')
            opt.should.equal(false)
        })
    })

    describe('#set("expires", "one hour")', function() {
        it('Should have expires option 3600', function() {
            var lactate = Lactate.Lactate()
            lactate.set('expires', 3600)
            var opt = lactate.get('expires')
            opt.should.equal(3600)
        })
    })

})

describe('Set Invalid', function() {

    describe('#set("asdf", "asdf")', function() {
        it('Should return an error', function() {
            var lactate = Lactate.Lactate()
            lactate.set('asdf', 'asdf')
            var opt = lactate.get('asdf')
            opt.should.be.an.instanceOf(Error)
        })
    })

    describe('#set("asdf")', function() {
        it('Should return an error', function() {
            var lactate = Lactate.Lactate()
            lactate.set('asdf')
            var opt = lactate.get('asdf')
            opt.should.be.an.instanceOf(Error)
        })
    })

    describe('#set()', function() {
        it('Should return an error', function() {
            var lactate = Lactate.Lactate()
            lactate.set()
            var opt = lactate.get('asdf')
            opt.should.be.an.instanceOf(Error)
        })
    })

})
