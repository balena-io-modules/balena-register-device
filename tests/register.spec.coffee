Promise = require 'bluebird'

_ = require 'lodash'
chai = require('chai')
expect = chai.expect
chai.use(require('chai-as-promised'))
errors = require('resin-errors')

API_ENDPOINT = 'https://api.resin.io'
PROVISIONING_KEY = 'abcd'
IS_BROWSER = window?

dataDirectory = null

if IS_BROWSER
	# The browser mock assumes global fetch prototypes exist
	# Can improve after https://github.com/wheresrhys/fetch-mock/issues/158
	realFetchModule = require('fetch-ponyfill')({ Promise })
	_.assign(global, _.pick(realFetchModule, 'Headers', 'Request', 'Response'))
else
	temp = require('temp').track()
	dataDirectory = temp.mkdirSync()

fetchMock = require('fetch-mock').sandbox(Promise)
# Promise sandbox config needs a little help. See:
# https://github.com/wheresrhys/fetch-mock/issues/159#issuecomment-268249788
fetchMock.fetchMock.Promise = Promise
require('resin-request/build/utils').fetch = fetchMock.fetchMock # Can become just fetchMock after issue above is fixed.

fetchMock.post "#{API_ENDPOINT}/device/register?apikey=#{PROVISIONING_KEY}", Promise.method (url, opts) ->
	user = JSON.parse(opts.body).user
	switch user
		when 1
			status: 401
			body: 'Unauthorized'
		when 2
			status: 201
			headers: 'content-type': 'application/json'
			body:
				id: 999
		else
			throw new Error("Unrecognised user for mocking '#{user}'")

token = require('resin-token')({ dataDirectory })
request = require('resin-request')({ token })
register = require('../lib/register')({ request })

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

		describe 'given the post operation is unsuccessful', ->

			it 'should return an error to the callback', (done) ->
				register.register
					userId: 1
					applicationId: 10350
					uuid: register.generateUniqueKey()
					deviceType: 'raspberry-pi'
					deviceApiKey: register.generateUniqueKey()
					provisioningApiKey: PROVISIONING_KEY
					apiEndpoint: API_ENDPOINT
				, (error, deviceInfo) ->
					expect(error).to.be.instanceof(errors.ResinRequestError)
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
					provisioningApiKey: PROVISIONING_KEY
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
					provisioningApiKey: PROVISIONING_KEY
					apiEndpoint: API_ENDPOINT

				expect(promise).to.eventually.deep.equal(id: 999)
