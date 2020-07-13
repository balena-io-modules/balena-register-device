# Change Log

All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).

## [5.0.0] - 2018-01-25

# v7.1.0
## (2020-07-13)

* Switch from randomstring to uuid for generating device uuids [Pagan Gazzard]

# v7.0.1
## (2020-07-13)

* Add .versionbot/CHANGELOG.yml for nested changelogs [Pagan Gazzard]

# v7.0.0
## (2020-07-06)

* Update to balena-request 11.x [Pagan Gazzard]
* Switch to returning native promises [Pagan Gazzard]
* Update to typed-error 3.x [Pagan Gazzard]
* Convert to typescript [Pagan Gazzard]
* Switch to a named export [Pagan Gazzard]
* Drop callback interface in favor of promise interface [Pagan Gazzard]

# v6.1.6
## (2020-05-26)

* Export ApiError [Cameron Diver]

# v6.1.5
## (2020-05-21)

* Convert tests to js [Thodoris Greasidis]

# v6.1.4
## (2020-05-21)

* Install typed-error v2 [Cameron Diver]

# v6.1.3
## (2020-05-20)

* Extend API exception to include full response object [Miguel Casqueira]

# v6.1.2
## (2020-05-20)

* Update mocha to fix node v12 deprecation warning [Thodoris Greasidis]

# v6.1.1
## (2020-04-27)

* Prevent balena-request from overwriting the authorization header [Thodoris Greasidis]
* Send the api key within the Authorisation header [Cameron Diver]

# v6.1.0
## (2020-04-17)

* Make user id optional [Pagan Gazzard]

## 6.0.1 - 2020-02-04

* GenerateUniqueKey: Reduce generated UUID size to 16 bytes. [James Harton]

## 6.0.0 - 2019-04-12

* Use a prepare step that doesn't run tests, to be balenaCI compliant [Thodoris Greasidis]
* Tests: Disable node 10 on appveyor since a warning is inferred as error [Thodoris Greasidis]
* Drop node 4 in favor of 8 & 10 on appveyor & travis [Thodoris Greasidis]
* Tests: Use balena-config-karma to get balenaCI compliance [Thodoris Greasidis]
* Tests: Use headless Chrome instead of phantomjs [Thodoris Greasidis]
* Tests: Use mockttp to test real requests, instead of fetch-mock [Thodoris Greasidis]
* Exclude the build output from the repo [Thodoris Greasidis]
* Rename everything 'resin' to 'balena' [Thodoris Greasidis]

### Changed

- Updated resin-request peer dependency to ^9.0.2

## [4.1.1] - 2018-01-25

### Changed

- Fixed tests

## [4.1.0] - 2017-04-10

### Changed

- Updated resin-request, removing the need to use a token in the provided resin-request instance

## [4.0.1] - 2017-01-06

### Changed

- Passing `refreshToken: false` to `resin-request` to save unnecessary request to `/whoami`
- Internal refactoring to tests
- Run Karma tests again

## [4.0.0] - 2017-01-04

### Changed

- **Breaking**: Moved to factory, in line with Resin-SDK, accepting a Resin-Request instance at runtime
- **Breaking**: Request errors are now thrown by Resin-Request directly, so their format has changed slightly:
	* Request timeouts now throw Promise.TimeoutError instead of raw Error, with the message "operation timed out" instead of "timeout"
	* Error responses from the server now throw ResinRequestError (see [resin-errors](https://github.com/resin-io-modules/resin-errors)) instead of raw Error, with the body prefixed with "Request error: "

## [3.0.0] - 2016-10-04

- Changed `register()` to work with the new device registration flow.
- Changed `generateUUID()` to `generateUniqueKey()` to reflect that it should now be used for both generating a uuid and an api key.

## [2.1.1] - 2016-10-03

### Changed

- Updated dependencies and optimize for SDK browser build.
- Switched to using the standardized resin-lint module for linting.

## [2.1.0] - 2016-02-18

### Added

- Add optional `apiPrefix` option.

## [2.0.1] - 2015-12-04

### Changed

- Omit tests in NPM package.

## [2.0.0] - 2015-09-02

### Changed

- Make `generateUUID()` asynchronous.
- Change `generateUUID()` to use `crypto.randomBytes()`.

## [1.1.0] - 2015-08-31

### Added

- Expose `generateUUID()`.
- Set `registered_at` to the current time when registering a device.

### Changed

- Fix documentation issues and inconsistencies on `register()`.
- Return the complete `device` object on `register()`.

## [1.0.1] - 2015-05-20

### Changed
- Do not throw sync exceptions on argument expectations.

[5.0.0]: https://github.com/resin-io-modules/resin-register-device/compare/v4.1.1...v5.0.0
[4.1.1]: https://github.com/resin-io-modules/resin-register-device/compare/v4.1.0...v4.1.1
[4.1.0]: https://github.com/resin-io-modules/resin-register-device/compare/v4.0.1...v4.1.0
[4.0.1]: https://github.com/resin-io-modules/resin-register-device/compare/v4.0.0...v4.0.1
[4.0.0]: https://github.com/resin-io-modules/resin-register-device/compare/v3.0.0...v4.0.0
[3.0.0]: https://github.com/resin-io-modules/resin-register-device/compare/v2.1.1...v3.0.0
[2.1.1]: https://github.com/resin-io-modules/resin-register-device/compare/v2.1.0...v2.1.1
[2.1.0]: https://github.com/resin-io-modules/resin-register-device/compare/v2.0.1...v2.1.0
[2.0.1]: https://github.com/resin-io-modules/resin-register-device/compare/v2.0.0...v2.0.1
[2.0.0]: https://github.com/resin-io-modules/resin-register-device/compare/v1.1.0...v2.0.0
[1.1.0]: https://github.com/resin-io-modules/resin-register-device/compare/v1.0.1...v1.1.0
[1.0.1]: https://github.com/resin-io-modules/resin-register-device/compare/v1.0.0...v1.0.1
