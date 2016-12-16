API_ENDPOINT = 'https://api.resin.io'

_ = require 'lodash'
chai = require('chai')
expect = chai.expect
chai.use(require('chai-as-promised'))

mockery = require('mockery')
mockery.enable(warnOnUnregistered: false)

# Required to get fetch-mock using bluebird.
# Can be dropped if https://github.com/wheresrhys/fetch-mock/issues/78 is resolved
global.Promise = require('bluebird')
fetchMock = require('fetch-mock').sandbox()

mockery.registerMock 'fetch-ponyfill', ->
	fetch: fetchMock

register = require('../lib/register')

describe 'Device Register:', ->

	beforeEach ->
		fetchMock.post "#{API_ENDPOINT}/device/register?apikey=asdf", (url, opts) ->
			user = JSON.parse(opts.body).user
			switch user
				when 1
					status: 401
					body: 'Unauthorized'
				when 2
					status: 201
					body:
						id: 999
				else
					throw new Error("Unrecognised user for mocking '#{user}'")

	afterEach ->
		fetchMock.restore()

	describe '.generateUniqueKey()', ->

		it 'should return a string that has a length of 62 (31 bytes)', ->
			uniqueKey = register.generateUniqueKey()
			expect(uniqueKey).to.be.a('string').that.has.lengthOf(62)

		it 'should generate different unique key each time', ->
			uniqueKeys = _.times(3, register.generateUUID)
			expect(uniqueKeys[0]).to.not.equal(uniqueKeys[1])
			expect(uniqueKeys[0]).to.not.equal(uniqueKeys[2])
			expect(uniqueKeys[1]).to.not.equal(uniqueKeys[2])

	describe '.register()', ->

		describe 'given the post operation is unsuccessful', ->

			it 'should return an error to the callback', (done) ->
				register.register
					userId: 1
					applicationId: 10350
					uuid: register.generateUniqueKey()
					deviceType: 'raspberry-pi'
					deviceApiKey: register.generateUniqueKey()
					provisioningApiKey: 'asdf'
					apiEndpoint: API_ENDPOINT
				, (error, deviceInfo) ->
					expect(error).to.be.an('error').that.has.a.property('message', 'Unauthorized')
					expect(deviceInfo).to.not.exist
					done()

				return

			it 'should return a rejected promise', ->
				promise = register.register
					userId: 1
					applicationId: 10350
					uuid: register.generateUniqueKey()
					deviceType: 'raspberry-pi'
					deviceApiKey: register.generateUniqueKey()
					provisioningApiKey: 'asdf'
					apiEndpoint: API_ENDPOINT
				expect(promise).to.eventually.be.rejectedWith(Error, 'Unauthorized')

		describe 'given the post operation is successful', ->

			it 'should return the resulting device info', (done) ->
				register.register
					userId: 2
					applicationId: 10350
					uuid: register.generateUniqueKey()
					deviceType: 'raspberry-pi'
					deviceApiKey: register.generateUniqueKey()
					provisioningApiKey: 'asdf'
					apiEndpoint: API_ENDPOINT
				, (error, deviceInfo) ->
					expect(error).to.not.exist
					expect(deviceInfo).to.deep.equal
						id: 999
					done()

				return

			it 'should return a promise that resolves to the device info', ->
				promise = register.register
					userId: 2
					applicationId: 10350
					uuid: register.generateUniqueKey()
					deviceType: 'raspberry-pi'
					deviceApiKey: register.generateUniqueKey()
					provisioningApiKey: 'asdf'
					apiEndpoint: API_ENDPOINT

				expect(promise).to.eventually.deep.equal(id: 999)
