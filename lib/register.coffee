_ = require('lodash')
crypto = require('crypto')

###*
# @summary Generate a device UUID
# @function
# @protected
#
# @returns {String} A generated UUID
#
# @example
# uuid = register.generateUUID()
###
exports.generateUUID = ->

	# I'd be nice if the UUID matched the output of a SHA-256 function,
	# but although the length limit of the CN attribute in a X.509
	# certificate is 64 chars, a 32 byte UUID (64 chars in hex) doesn't
	# pass the certificate validation in OpenVPN This either means that
	# the RFC counts a final NULL byte as part of the CN or that the
	# OpenVPN/OpenSSL implementation has a bug.
	return crypto.pseudoRandomBytes(31).toString('hex')

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
#		device_type: 'raspberry-pi'
#		apiKey: '...'
#	, (error, device) ->
#		throw error if error?
#		console.log(device)
###
exports.register = (pineInstance, options, callback) ->
	pineInstance.post
		resource: 'device'
		body:
			user: options.userId
			application: options.applicationId
			uuid: options.uuid or exports.generateUUID()
			device_type: options.deviceType
		customOptions:
			apikey: options.apiKey

	.then (data) ->
		return _.pick(data, 'id', 'uuid')

	# Allow promise based and callback based styles
	.nodeify(callback)
