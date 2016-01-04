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
_ = require('lodash')
crypto = require('crypto')

###*
# @summary Generate a device UUID
# @function
# @public
#
# @description
# This function allows promise style if the callback is omitted.
#
# @param {Function} callback - callback (error, uuid)
#
# @example
# deviceRegister.generateUUID (error, uuid) ->
# 	throw error if error?
#	# uuid is a generated UUID that can be used for registering
# 	console.log(uuid)
###
exports.generateUUID = (callback) ->

	# I'd be nice if the UUID matched the output of a SHA-256 function,
	# but although the length limit of the CN attribute in a X.509
	# certificate is 64 chars, a 32 byte UUID (64 chars in hex) doesn't
	# pass the certificate validation in OpenVPN This either means that
	# the RFC counts a final NULL byte as part of the CN or that the
	# OpenVPN/OpenSSL implementation has a bug.
	Promise.try ->
		crypto.randomBytes(31).toString('hex')
	.catch ->
		Promise.delay(1).then(exports.generateUUID)
	.nodeify(callback)

###*
# @summary Register a device with Resin.io
# @function
# @public
#
# @description
# This function allows promise style if the callback is omitted.
#
# @param {Object} pineInstance - pine instance
# @param {Object} options - options
# @param {Number} options.userId - user id
# @param {Number} options.applicationId - application id
# @param {String} options.deviceType - device type
# @param {String} options.apiKey - api key
# @param {String} [options.uuid] - device uuid
# @param {Function} callback - callback (error, device)
#
# @example
# pine = require('resin-pine')
#
# deviceRegister.register pine,
#		userId: 199
#		applicationId: 10350
#		deviceType: 'raspberry-pi'
#		apiKey: '...'
#	, (error, device) ->
#		throw error if error?
#		console.log(device)
###
exports.register = (pineInstance, options, callback) ->
	Promise.try ->
		return options.uuid or exports.generateUUID()
	.then (uuid) ->
		pineInstance.post
			resource: 'device'
			body:
				user: options.userId
				application: options.applicationId
				uuid: uuid
				device_type: options.deviceType
				registered_at: Math.floor(Date.now() / 1000)
			customOptions:
				apikey: options.apiKey
	# Allow promise based and callback based styles
	.nodeify(callback)
