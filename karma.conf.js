const getKarmaConfig = require('balena-config-karma');
const packageJSON = require('./package.json');

module.exports = (config) => {
	const karmaConfig = getKarmaConfig(packageJSON);
	karmaConfig.logLevel = config.LOG_INFO;
	// polyfill required for mockttp & balena-request
	// the next major might not require them any more
	karmaConfig.webpack.resolve.fallback = {
		assert: false,
		crypto: false,
		fs: false,
		path: false,
		querystring: require.resolve('querystring-es3'),
		stream: require.resolve('stream-browserify'),
		url: false,
		util: false,
		zlib: require.resolve('browserify-zlib'),
	};
	karmaConfig.webpack.plugins = [
		new getKarmaConfig.webpack.ProvidePlugin({
			// Polyfills or mocks for various node stuff
			process: 'process/browser',
			Buffer: ['buffer', 'Buffer'],
		}),
	];
	karmaConfig.webpack.experiments = {
		asyncWebAssembly: true,
	};

	config.set(karmaConfig);
};
