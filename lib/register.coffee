###
Copyright 2016 Resin.io

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
postAsync = Promise.promisify(require('request').post, multiArgs: true)
randomstring = require('randomstring')

###*
# @summary Generate a random key, useful for both uuid and api key.
# @function
# @public
#
# @description
# This function allows promise style if the callback is omitted.
#
# @param {Function} callback - callback (error, randomKey)
#
# @example
# deviceRegister.generateUniqueKey (error, randomKey) ->
#  	throw error if error?
# 	# randomKey is a randomly generated key that can be used as either a uuid or an api key
# 	console.log(randomKey)
###
exports.generateUniqueKey = ->
	# It'd be nice if the random key matched the output of a SHA-256 function,
	# but for the purposes of a uuid we are limited by the fact that
	# although the length limit of the CN attribute in a X.509
	# certificate is 64 chars, a 32 byte UUID (64 chars in hex) doesn't
	# pass the certificate validation in OpenVPN This either means that
	# the RFC counts a final NULL byte as part of the CN or that the
	# OpenVPN/OpenSSL implementation has a bug.
	return randomstring.generate(
		length: 62
		charset: 'hex'
	)

###*
# @summary Register a device with Resin.io
# @function
# @public
#
# @description
# This function allows promise style if the callback is omitted.
#
# @param {Object} options - options
# @param {Number} options.userId - user id
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
#		apiEndpoint: 'https://api.resin.io'
#	, (error, deviceInfo) ->
#		throw error if error?
#		console.log(deviceInfo) # { id }
###
exports.register = Promise.method (options, callback) ->
	for opt in [ 'userId', 'applicationId', 'uuid', 'deviceType', 'provisioningApiKey', 'apiEndpoint']
		if !options[opt]?
			throw new Error("Options must contain a '#{opt}' entry.")
	postAsync
		method: 'POST'
		url: "#{options.apiEndpoint}/device/register?apikey=#{options.provisioningApiKey}"
		timeout: 30000
		gzip: true
		json: true
		body:
			user: options.userId
			application: options.applicationId
			uuid: options.uuid
			device_type: options.deviceType
			api_key: options.deviceApiKey
	.tap ([{ statusCode }, body]) ->
		if statusCode isnt 201
			throw new Error(body)
	.get(1)
	# Allow promise based and callback based styles
	.asCallback(callback)
