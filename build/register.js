var crypto, _;

_ = require('lodash');

crypto = require('crypto');


/**
 * @summary Generate a device UUID
 * @function
 * @public
 *
 * @returns {String} A generated UUID
 *
 * @example
 * uuid = register.generateUUID()
 */

exports.generateUUID = function() {
  return crypto.randomBytes(31).toString('hex');
};


/**
 * @summary Register a device with Resin.io
 * @function
 * @public
 *
 * @description
 * This function allows promise style if the callback is omitted.
 *
 * @param {Object} pineInstance - pine instance
 * @param {Object} options - options
 * @param {Number} options.userId - user id
 * @param {Number} options.applicationId - application id
 * @param {String} options.deviceType - device type
 * @param {String} options.apiKey - api key
 * @param {String} [options.uuid] - device uuid
 * @param {Function} callback - callback (error, device)
 *
 * @example
 * pine = require('resin-pine')
 *
 * deviceRegister.register pine,
 *		userId: 199
 *		applicationId: 10350
 *		deviceType: 'raspberry-pi'
 *		apiKey: '...'
 *	, (error, device) ->
 *		throw error if error?
 *		console.log(device)
 */

exports.register = function(pineInstance, options, callback) {
  return pineInstance.post({
    resource: 'device',
    body: {
      user: options.userId,
      application: options.applicationId,
      uuid: options.uuid || exports.generateUUID(),
      device_type: options.deviceType
    },
    customOptions: {
      apikey: options.apiKey
    }
  }).nodeify(callback);
};
