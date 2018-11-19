module.exports = {
	presets: [
		["@babel/preset-typescript"],
		["@babel/preset-env",
			{
				"debug": false,
				"modules": "commonjs",
				"targets": {
					"node": "current"
				}
			}
		]
	],

	plugins: [
		"@babel/plugin-proposal-export-default-from",
		"@babel/plugin-proposal-export-namespace-from",
		"@babel/plugin-proposal-object-rest-spread",
		"@babel/plugin-proposal-class-properties",
		"@babel/plugin-syntax-dynamic-import",
		"@babel/plugin-transform-classes",
	],

	comments: false
};
