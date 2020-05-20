###
Copyright 2016 Balena

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

   http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
###

Promise = require('bluebird')
randomstring = require('randomstring')
{ TypedError } = require 'typed-error'

###*
# @summary Creates a Balena Register Device instance
# @function
# @public
#
# @returns {Object} Balena Register Device instance { generateUniqueKey: ..., register: ... }
###
module.exports = ({ request }) ->
	###*
	# @summary Generate a random key, useful for both uuid and api key.
	# @function
	# @public
	#
	# @returns {String} A generated key
	#
	# @example
	# randomKey = deviceRegister.generateUniqueKey()
	# # randomKey is a randomly generated key that can be used as either a uuid or an api key
	# console.log(randomKey)
	###
	generateUniqueKey: ->
		return randomstring.generate(
			length: 32
			charset: 'hex'
		)

	###*
	# @summary Register a device with Balena
	# @function
	# @public
	#
	# @description
	# This function allows promise style if the callback is omitted.
	#
	# @param {Object} options - options
	# @param {Number} [options.userId] - user id
	# @param {Number} options.applicationId - application id
	# @param {String} options.uuid - device uuid
	# @param {String} options.deviceType - device type
	# @param {String} options.deviceApiKey - api key to create for the device
	# @param {String} options.provisioningApiKey - provisioning api key
	# @param {String} options.apiEndpoint - api endpoint
	# @param {Function} [callback] - callback (error, deviceInfo)
	#
	# @example
	# deviceRegister.register
	#		userId: 199
	#		applicationId: 10350
	#		uuid: '...'
	#		deviceType: 'raspberry-pi'
	#		deviceApiKey: '...'
	#		provisioningApiKey: '...'
	#		apiEndpoint: 'https://api.balena-cloud.com'
	#	, (error, deviceInfo) ->
	#		throw error if error?
	#		console.log(deviceInfo) # { id }
	###
	register: Promise.method (options, callback) ->
		for opt in [ 'applicationId', 'uuid', 'deviceType', 'provisioningApiKey', 'apiEndpoint' ]
			if !options[opt]?
				throw new Error("Options must contain a '#{opt}' entry.")

		request.send
			method: 'POST'
			baseUrl: options.apiEndpoint
			url: '/device/register'
			refreshToken: false
			sendToken: false
			headers:
				Authorization: "Bearer #{options.provisioningApiKey}"
			timeout: 30000
			body:
				user: options.userId
				application: options.applicationId
				uuid: options.uuid
				device_type: options.deviceType
				api_key: options.deviceApiKey
		.tap (response) ->
			if response.statusCode isnt 201
				throw new ApiError(response.body, response)
		.get('body')
		# Allow promise based and callback based styles
		.asCallback(callback)

class ApiError extends TypedError
	constructor: (message = 'Error with API request', @response) ->
		super(@message)
