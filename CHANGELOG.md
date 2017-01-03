# Change Log

All notable changes to this project will be documented in this file.
This project adheres to [Semantic Versioning](http://semver.org/).

### Changed

- **Breaking**: Moved to factory, in line with Resin-SDK, accepting a data directory at runtime
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

[2.1.0]: https://github.com/resin-io-modules/resin-register-device/compare/v2.0.1...v2.1.0
[2.0.1]: https://github.com/resin-io-modules/resin-register-device/compare/v2.0.0...v2.0.1
[2.0.0]: https://github.com/resin-io-modules/resin-register-device/compare/v1.1.0...v2.0.0
[1.1.0]: https://github.com/resin-io-modules/resin-register-device/compare/v1.0.1...v1.1.0
[1.0.1]: https://github.com/resin-io-modules/resin-register-device/compare/v1.0.0...v1.0.1
