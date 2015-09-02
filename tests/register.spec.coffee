Promise = require('bluebird')
_ = require('lodash')
chai = require('chai')
expect = chai.expect
sinon = require('sinon')
chai.use(require('sinon-chai'))
chai.use(require('chai-as-promised'))
register = require('../lib/register')

describe 'Device Register:', ->

	describe '.generateUUID()', ->

		it 'should return a string in its callback', (done) ->
			register.generateUUID (err, uuid) ->
				expect(uuid).to.be.a('string')
				done()

		it 'should return a string if called in Promise mode', (done) ->
			register.generateUUID()
			.then (uuid) ->
				expect(uuid).to.be.a('string')
				done()

		it 'should have a length of 62 (31 bytes)', (done) ->
			register.generateUUID (err, uuid) ->
				expect(uuid).to.have.length(62)
				done()

		it 'should generate different uuids each time', (done) ->
			Promise.all([
				register.generateUUID()
				register.generateUUID()
				register.generateUUID()
			]).then ([ uuid1, uuid2, uuid3 ]) ->
				expect(uuid1).to.not.equal(uuid2)
				expect(uuid2).to.not.equal(uuid3)
				expect(uuid3).to.not.equal(uuid1)
				done()

	describe '.register()', ->

		describe 'given the post operation is unsuccessful', ->

			beforeEach ->
				@error = new Error('pine error')
				@pineInstance =
					post: => Promise.reject(@error)

			it 'should return an error to the callback', (done) ->
				register.register @pineInstance,
					userId: 199
					applicationId: 10350
					deviceType: 'raspberry-pi'
					uuid: 'asdf'
					apiKey: 'asdf'
				, (error, device) =>
					expect(error).to.equal(@error)
					expect(device).to.not.exist
					done()

			it 'should return a rejected promise if no callback', ->
				promise = register.register @pineInstance,
					userId: 199
					applicationId: 10350
					deviceType: 'raspberry-pi'
					uuid: 'asdf'
					apiKey: 'asdf'
				expect(promise).to.eventually.be.rejectedWith(@error)

		describe 'given the post operation is successful', ->

			beforeEach ->
				@pineInstance =
					post: -> Promise.resolve
						id: 999
						userId: 199
						applicationId: 10350
						deviceType: 'raspberry-pi'
						uuid: 'asdf'
						apiKey: 'asdf'

			it 'should return the resulting device', (done) ->
				register.register @pineInstance,
					userId: 199
					applicationId: 10350
					deviceType: 'raspberry-pi'
					uuid: 'asdf'
					apiKey: 'asdf'
				, (error, device) ->
					expect(error).to.not.exist
					expect(device).to.deep.equal
						id: 999
						userId: 199
						applicationId: 10350
						deviceType: 'raspberry-pi'
						uuid: 'asdf'
						apiKey: 'asdf'
					done()

			it 'should return a promise that resolves the device if no callback', ->
				promise = register.register @pineInstance,
					userId: 199
					applicationId: 10350
					deviceType: 'raspberry-pi'
					uuid: 'asdf'
					apiKey: 'asdf'

				expect(promise).to.eventually.deep.equal
					id: 999
					userId: 199
					applicationId: 10350
					deviceType: 'raspberry-pi'
					uuid: 'asdf'
					apiKey: 'asdf'

			describe 'given a explicit uuid', ->

				it 'should call pineInstance.post() with that uuid', (done) ->
					postSpy = sinon.spy(@pineInstance, 'post')

					register.register @pineInstance,
						userId: 199
						applicationId: 10350
						deviceType: 'raspberry-pi'
						uuid: 'asdf'
						apiKey: 'asdf'
					, ->
						expect(postSpy).to.have.been.calledOnce
						expect(postSpy.args[0][0].body.uuid).to.equal('asdf')
						postSpy.restore()
						done()

			describe 'given no uuid', ->

				it 'should call pineInstance.post() with a generated uuid', (done) ->
					postSpy = sinon.spy(@pineInstance, 'post')

					register.register @pineInstance,
						userId: 199
						applicationId: 10350
						deviceType: 'raspberry-pi'
						apiKey: 'asdf'
					, ->
						expect(postSpy).to.have.been.calledOnce
						expect(postSpy.args[0][0].body.uuid).to.exist
						expect(postSpy.args[0][0].body.uuid).to.have.length(62)
						postSpy.restore()
						done()
