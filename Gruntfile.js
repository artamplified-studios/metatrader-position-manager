module.exports = function(grunt) {

	var dist = '/Applications/XM.app/Contents/Resources/drive_c/Program Files/XM MT4/MQL4/Experts/position-manager';

	grunt.initConfig({

		copy: {
			main: {
				files:[
					{src: 'position-manager.mq4', dest: '/Users/Mertopawiro/Applications/Wineskin/xm-demo.app/Contents/Resources/drive_c/Program Files/MetaTrader 4/MQL4/Experts/position manager/position-manager.mq4'}
				]
			}
		},

		watch: {
			scripts: {
				files: ['position-manager.mq4'],
				tasks: ['copy'],
				options: {
					debounceDelay: 250,
				},
			},
		},

	});

	grunt.loadNpmTasks('grunt-contrib-copy');
	grunt.loadNpmTasks('grunt-contrib-watch');

	grunt.registerTask('default', ['copy', 'watch']);

};