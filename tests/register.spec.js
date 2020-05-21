const _ = require('lodash');
const chai = require('chai');
const { expect } = chai;
chai.use(require('chai-as-promised'));
const errors = require('balena-errors');
const getRequest = require('balena-request');
const mockServer = require('mockttp').getLocal();

const request = getRequest();
const register = require('../lib/register')({ request });

const PROVISIONING_KEY = 'abcd';

describe('Device Register:', function () {
	describe('.generateUniqueKey()', function () {
		it('should return a string that has a length of 32 (16 bytes)', function () {
			const uniqueKey = register.generateUniqueKey();
			expect(uniqueKey).to.be.a('string').that.has.lengthOf(32);
		});

		it('should generate different unique key each time', function () {
			const uniqueKeys = _.times(3, register.generateUUID);
			expect(uniqueKeys[0]).to.not.equal(uniqueKeys[1]);
			expect(uniqueKeys[0]).to.not.equal(uniqueKeys[2]);
			expect(uniqueKeys[1]).to.not.equal(uniqueKeys[2]);
		});
	});

	describe('.register()', function () {
		before(() =>
			mockServer.start().then(() =>
				mockServer.post('/device/register').thenCallback(function (req) {
					if (req.headers.authorization !== `Bearer ${PROVISIONING_KEY}`) {
						throw new Error(
							`No or incorrect authorization header: ${req.headers.authorization}`,
						);
					}
					const { user } = JSON.parse(req.body.text);
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
			it('should return an error to the callback', function (done) {
				register.register(
					{
						userId: 1,
						applicationId: 10350,
						uuid: register.generateUniqueKey(),
						deviceType: 'raspberry-pi',
						deviceApiKey: register.generateUniqueKey(),
						provisioningApiKey: PROVISIONING_KEY,
						apiEndpoint: mockServer.url,
					},
					function (error, deviceInfo) {
						expect(error).to.be.instanceof(errors.BalenaRequestError);
						expect(error).to.have.a.property(
							'message',
							'Request error: Unauthorized',
						);
						expect(deviceInfo).to.not.exist;
						done();
					},
				);
			});

			it('should return a rejected promise', function () {
				const promise = register.register({
					userId: 1,
					applicationId: 10350,
					uuid: register.generateUniqueKey(),
					deviceType: 'raspberry-pi',
					deviceApiKey: register.generateUniqueKey(),
					provisioningApiKey: PROVISIONING_KEY,
					apiEndpoint: mockServer.url,
				});

				return expect(promise).to.eventually.be.rejectedWith(
					Error,
					'Unauthorized',
				);
			});
		});

		describe('given the post operation is successful', function () {
			it('should return the resulting device info', function (done) {
				register.register(
					{
						userId: 2,
						applicationId: 10350,
						uuid: register.generateUniqueKey(),
						deviceType: 'raspberry-pi',
						deviceApiKey: register.generateUniqueKey(),
						provisioningApiKey: PROVISIONING_KEY,
						apiEndpoint: mockServer.url,
					},
					function (error, deviceInfo) {
						expect(error).to.not.exist;
						expect(deviceInfo).to.deep.equal({
							id: 999,
						});
						done();
					},
				);
			});

			it('should return a promise that resolves to the device info', function () {
				const promise = register.register({
					userId: 2,
					applicationId: 10350,
					uuid: register.generateUniqueKey(),
					deviceType: 'raspberry-pi',
					deviceApiKey: register.generateUniqueKey(),
					provisioningApiKey: PROVISIONING_KEY,
					apiEndpoint: mockServer.url,
				});

				return expect(promise).to.eventually.deep.equal({ id: 999 });
			});
		});
	});
});
