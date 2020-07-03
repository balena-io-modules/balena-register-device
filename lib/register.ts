/*
Copyright 2016-2020 Balena Ltd.

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

import * as randomstring from 'randomstring';
import { TypedError } from 'typed-error';

interface SendResponse {
	statusCode: number;
	body: any;
}

/**
 * @summary Creates a Balena Register Device instance
 * @function
 * @public
 *
 * @returns {Object} Balena Register Device instance { generateUniqueKey: ..., register: ... }
 */
export const getRegisterDevice = ({
	request,
}: {
	request: {
		send: (opts: {
			method?: 'GET' | 'POST' | 'PUT' | 'DELETE' | 'PATCH' | 'HEAD' | 'OPTIONS';
			baseUrl?: string;
			url: string;
			refreshToken?: boolean;
			sendToken?: boolean;
			body?: any;
			responseFormat?: 'none' | 'blob' | 'json' | 'text';
			headers: {
				[key: string]: string;
			};
			timeout: number;
		}) => Promise<SendResponse>;
	};
}) => ({
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
	generateUniqueKey() {
		return randomstring.generate({
			length: 32,
			charset: 'hex',
		});
	},

	/**
	 * @summary Register a device with Balena
	 * @function
	 * @public
	 *
	 * @param {Object} options - options
	 * @param {Number} [options.userId] - user id
	 * @param {Number} options.applicationId - application id
	 * @param {String} options.uuid - device uuid
	 * @param {String} options.deviceType - device type
	 * @param {String} options.deviceApiKey - api key to create for the device
	 * @param {String} options.provisioningApiKey - provisioning api key
	 * @param {String} options.apiEndpoint - api endpoint
	 *
	 * @example
	 * deviceRegister.register
	 * 		userId: 199
	 * 		applicationId: 10350
	 * 		uuid: '...'
	 * 		deviceType: 'raspberry-pi'
	 * 		deviceApiKey: '...'
	 * 		provisioningApiKey: '...'
	 * 		apiEndpoint: 'https://api.balena-cloud.com'
	 * 	.then (deviceInfo) ->
	 * 		console.log(deviceInfo) # { id }
	 */
	async register(options: {
		userId?: number;
		applicationId: number;
		uuid: string;
		deviceType: string;
		deviceApiKey?: string;
		provisioningApiKey: string;
		apiEndpoint: string;
	}) {
		for (const opt of [
			'applicationId',
			'uuid',
			'deviceType',
			'provisioningApiKey',
			'apiEndpoint',
		] as const) {
			if (options[opt] == null) {
				throw new Error(`Options must contain a '${opt}' entry.`);
			}
		}

		const response = await request.send({
			method: 'POST',
			baseUrl: options.apiEndpoint,
			url: '/device/register',
			refreshToken: false,
			sendToken: false,
			headers: {
				Authorization: `Bearer ${options.provisioningApiKey}`,
			},
			timeout: 30000,
			body: {
				user: options.userId,
				application: options.applicationId,
				uuid: options.uuid,
				device_type: options.deviceType,
				api_key: options.deviceApiKey,
			},
		});
		if (response.statusCode !== 201) {
			throw new ApiError(response.body, response);
		}
		return response.body;
	},
});

export class ApiError extends TypedError {
	constructor(
		message = 'Error with API request',
		public response: SendResponse,
	) {
		super(message);
	}
}
