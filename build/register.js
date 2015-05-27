var crypto, errors, _;

_ = require('lodash');

errors = require('resin-errors');

crypto = require('./crypto');


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
 *		device_type: 'raspberry-pi'
 *		apiKey: '...'
 *	, (error, device) ->
 *		throw error if error?
 *		console.log(device)
 */

exports.register = function(pineInstance, options, callback) {
  if (pineInstance == null) {
    throw new errors.ResinMissingParameter('pine instance');
  }
  if (options == null) {
    throw new errors.ResinMissingParameter('options');
  }
  return pineInstance.post({
    resource: 'device',
    body: {
      user: options.userId,
      application: options.applicationId,
      uuid: options.uuid || crypto.generateUUID(),
      device_type: options.deviceType
    },
    customOptions: {
      apikey: options.apiKey
    }
  }).then(function(data) {
    return _.pick(data, 'id', 'uuid');
  }).nodeify(callback);
};
