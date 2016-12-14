
/*
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
 */
var Promise, postAsync, randomstring;

Promise = require('bluebird');

postAsync = Promise.promisify(require('request').post, {
  multiArgs: true
});

randomstring = require('randomstring');


/**
 * @summary Generate a random key, useful for both uuid and api key.
 * @function
 * @public
 *
 * @returns {String} A generated key
 *
 * @example
 * randomKey = deviceRegister.generateUniqueKey()
 * # randomKey is a randomly generated key that can be used as either a uuid or an api key
 * console.log(randomKey)
 */

exports.generateUniqueKey = function() {
  return randomstring.generate({
    length: 62,
    charset: 'hex'
  });
};


/**
 * @summary Register a device with Resin.io
 * @function
 * @public
 *
 * @description
 * This function allows promise style if the callback is omitted.
 *
 * @param {Object} options - options
 * @param {Number} options.userId - user id
 * @param {Number} options.applicationId - application id
 * @param {String} options.uuid - device uuid
 * @param {String} options.deviceType - device type
 * @param {String} options.deviceApiKey - api key to create for the device
 * @param {String} options.provisioningApiKey - provisioning api key
 * @param {String} options.apiEndpoint - api endpoint
 * @param {Function} [callback] - callback (error, deviceInfo)
 *
 * @example
 * deviceRegister.register
 *		userId: 199
 *		applicationId: 10350
 *		uuid: '...'
 *		deviceType: 'raspberry-pi'
 *		deviceApiKey: '...'
 *		provisioningApiKey: '...'
 *		apiEndpoint: 'https://api.resin.io'
 *	, (error, deviceInfo) ->
 *		throw error if error?
 *		console.log(deviceInfo) # { id }
 */

exports.register = Promise.method(function(options, callback) {
  var i, len, opt, ref;
  ref = ['userId', 'applicationId', 'uuid', 'deviceType', 'provisioningApiKey', 'apiEndpoint'];
  for (i = 0, len = ref.length; i < len; i++) {
    opt = ref[i];
    if (options[opt] == null) {
      throw new Error("Options must contain a '" + opt + "' entry.");
    }
  }
  return postAsync({
    method: 'POST',
    url: options.apiEndpoint + "/device/register?apikey=" + options.provisioningApiKey,
    timeout: 30000,
    gzip: true,
    json: true,
    body: {
      user: options.userId,
      application: options.applicationId,
      uuid: options.uuid,
      device_type: options.deviceType,
      api_key: options.deviceApiKey
    }
  }).tap(function(arg) {
    var body, ref1, statusCode;
    (ref1 = arg[0], statusCode = ref1.statusCode), body = arg[1];
    if (statusCode !== 201) {
      throw new Error(body);
    }
  }).get(1).asCallback(callback);
});
