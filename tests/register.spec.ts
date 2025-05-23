import * as _ from 'lodash';
import { expect } from 'chai';
import * as errors from 'balena-errors';
import { getRequest } from 'balena-request';
import * as mockttp from 'mockttp';

const mockServer = mockttp.getLocal();
const request = getRequest({});
import { getRegisterDevice } from '../build/register';
const register = getRegisterDevice({ request });

const PROVISIONING_KEY = 'abcd';

describe('Device Register:', function () {
	describe('.generateUniqueKey()', function () {
		it('should return a string that has a length of 32 (16 bytes)', function () {
			const uniqueKey = register.generateUniqueKey();
			expect(uniqueKey).to.be.a('string').that.has.lengthOf(32);
		});

		it('should generate different unique key each time', function () {
			const uniqueKeys = _.times(3, register.generateUniqueKey);
			expect(uniqueKeys[0]).to.not.equal(uniqueKeys[1]);
			expect(uniqueKeys[0]).to.not.equal(uniqueKeys[2]);
			expect(uniqueKeys[1]).to.not.equal(uniqueKeys[2]);
		});
	});

	describe('.register()', function () {
		before(() =>
			mockServer.start().then(() =>
				mockServer
					.forPost('/device/register')
					.thenCallback(async function (req) {
						if (req.headers.authorization !== `Bearer ${PROVISIONING_KEY}`) {
							throw new Error(
								`No or incorrect authorization header: ${req.headers.authorization}`,
							);
						}
						const { user } = JSON.parse((await req.body.getText())!);
						switch (user) {
							case 1:
								return {
									status: 401,
									body: 'Unauthorized',
								};
							case 2:
								return {
									status: 201,
									json: {
										id: 999,
									},
								};
							default:
								throw new Error(`Unrecognised user for mocking '${user}'`);
						}
					}),
			),
		);

		after(() => mockServer.stop());

		describe('given the post operation is unsuccessful', function () {
			it('should return an error to the callback', function () {
				return register
					.register({
						userId: 1,
						applicationId: 10350,
						uuid: register.generateUniqueKey(),
						deviceType: 'raspberry-pi',
						deviceApiKey: register.generateUniqueKey(),
						provisioningApiKey: PROVISIONING_KEY,
						apiEndpoint: mockServer.url,
					})
					.then(() => {
						throw new Error('Succeeded');
					})
					.catch(function (error: Error) {
						expect(error).to.be.instanceof(errors.BalenaRequestError);
						expect(error).to.have.a.property(
							'message',
							'Request error: Unauthorized',
						);
					});
			});

			it('should return a rejected promise', async function () {
				let err;
				try {
					await register.register({
						userId: 1,
						applicationId: 10350,
						uuid: register.generateUniqueKey(),
						deviceType: 'raspberry-pi',
						deviceApiKey: register.generateUniqueKey(),
						provisioningApiKey: PROVISIONING_KEY,
						apiEndpoint: mockServer.url,
					});
				} catch ($err) {
					err = $err;
				}
				expect(err)
					.to.be.an.instanceOf(Error)
					.with.property('message', 'Request error: Unauthorized');
			});
		});

		describe('given the post operation is successful', function () {
			it('should return the resulting device info', function () {
				return register
					.register({
						userId: 2,
						applicationId: 10350,
						uuid: register.generateUniqueKey(),
						deviceType: 'raspberry-pi',
						deviceApiKey: register.generateUniqueKey(),
						provisioningApiKey: PROVISIONING_KEY,
						apiEndpoint: mockServer.url,
					})
					.then(function (deviceInfo) {
						expect(deviceInfo).to.deep.equal({
							id: 999,
						});
					});
			});

			it('should return a promise that resolves to the device info', async function () {
				const result = await register.register({
					userId: 2,
					applicationId: 10350,
					uuid: register.generateUniqueKey(),
					deviceType: 'raspberry-pi',
					deviceApiKey: register.generateUniqueKey(),
					provisioningApiKey: PROVISIONING_KEY,
					apiEndpoint: mockServer.url,
				});

				return expect(result).to.deep.equal({ id: 999 });
			});
		});
	});
});
