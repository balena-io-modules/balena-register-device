_ = require 'lodash'
chai = require('chai')
expect = chai.expect
chai.use(require('chai-as-promised'))
errors = require('balena-errors')
getRequest = require('balena-request')
mockServer = require('mockttp').getLocal()

request = getRequest()
register = require('../lib/register')({ request })

PROVISIONING_KEY = 'abcd'

describe 'Device Register:', ->

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

		before ->
			mockServer.start().then ->
				mockServer.post("/device/register?apikey=#{PROVISIONING_KEY}").thenCallback (req) ->
					user = JSON.parse(req.body.text).user
					switch user
						when 1
							status: 401
							body: 'Unauthorized'
						when 2
							status: 201
							json:
								id: 999
						else
							throw new Error("Unrecognised user for mocking '#{user}'")

		after ->
			mockServer.stop()

		describe 'given the post operation is unsuccessful', ->

			it 'should return an error to the callback', (done) ->
				register.register
					userId: 1
					applicationId: 10350
					uuid: register.generateUniqueKey()
					deviceType: 'raspberry-pi'
					deviceApiKey: register.generateUniqueKey()
					provisioningApiKey: PROVISIONING_KEY
					apiEndpoint: mockServer.url
				, (error, deviceInfo) ->
					expect(error).to.be.instanceof(errors.BalenaRequestError)
					expect(error).to.have.a.property('message', 'Request error: Unauthorized')
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
					provisioningApiKey: PROVISIONING_KEY
					apiEndpoint: mockServer.url
				expect(promise).to.eventually.be.rejectedWith(Error, 'Unauthorized')

		describe 'given the post operation is successful', ->

			it 'should return the resulting device info', (done) ->
				register.register
					userId: 2
					applicationId: 10350
					uuid: register.generateUniqueKey()
					deviceType: 'raspberry-pi'
					deviceApiKey: register.generateUniqueKey()
					provisioningApiKey: PROVISIONING_KEY
					apiEndpoint: mockServer.url
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
					provisioningApiKey: PROVISIONING_KEY
					apiEndpoint: mockServer.url

				expect(promise).to.eventually.deep.equal(id: 999)
