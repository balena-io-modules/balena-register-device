crypto = require('crypto')

###*
# @summary Generate a device UUID
# @function
# @protected
#
# @returns {String} A generated UUID
#
# @example
# uuid = crypto.generateUUID()
###
exports.generateUUID = ->

	# I'd be nice if the UUID matched the output of a SHA-256 function,
	# but although the length limit of the CN attribute in a X.509
	# certificate is 64 chars, a 32 byte UUID (64 chars in hex) doesn't
	# pass the certificate validation in OpenVPN This either means that
	# the RFC counts a final NULL byte as part of the CN or that the
	# OpenVPN/OpenSSL implementation has a bug.
	return crypto.pseudoRandomBytes(31).toString('hex')
