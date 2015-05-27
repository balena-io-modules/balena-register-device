var crypto;

crypto = require('crypto');


/**
 * @summary Generate a device UUID
 * @function
 * @protected
 *
 * @returns {String} A generated UUID
 *
 * @example
 * uuid = crypto.generateUUID()
 */

exports.generateUUID = function() {
  return crypto.pseudoRandomBytes(31).toString('hex');
};
