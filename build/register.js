var Promise, crypto, _;

Promise = require('bluebird');

_ = require('lodash');

crypto = require('crypto');


/**
 * @summary Generate a device UUID
 * @function
 * @public
 *
 * @description
 * This function allows promise style if the callback is omitted.
 *
 * @param {Function} callback - callback (error, uuid)
 *
 * @example
 * deviceRegister.generateUUID (err, uuid) ->
 * 	throw err if err?
 *	# uuid is a generated UUID that can be used for registering
 * 	console.log(uuid)
 */

exports.generateUUID = function(callback) {
  return Promise["try"](function() {
    return crypto.randomBytes(31).toString('hex');
  })["catch"](function() {
    return Promise.delay(1).then(function() {
      return exports.generateUUID();
    });
  }).nodeify(callback);
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
  return Promise["try"](function() {
    return options.uuid || exports.generateUUID();
  }).then(function(uuid) {
    return pineInstance.post({
      resource: 'device',
      body: {
        user: options.userId,
        application: options.applicationId,
        uuid: uuid,
        device_type: options.deviceType,
        registered_at: Math.floor(Date.now() / 1000)
      },
      customOptions: {
        apikey: options.apiKey
      }
    });
  }).nodeify(callback);
};
