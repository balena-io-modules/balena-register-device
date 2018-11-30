declare module 'resin-register-device' {
	import * as Bluebird from 'bluebird';

	interface RegisterOpts {
		userId: number;
		applicationId: number;
		uuid: string;
		deviceType: string;
		deviceApiKey: string;
		provisioningApiKey: string;
		apiEndpoint: string;
	}

	interface ResinRegisterDevice {
		generateUniqueKey: () => string;
		register: (
			regOpts: RegisterOpts,
			cb: (err: Error | undefined, deviceInfo: any) => void,
		) => Bluebird<string>;
	}

	function init(opts: { request: any }): ResinRegisterDevice;

	export = init;
}
