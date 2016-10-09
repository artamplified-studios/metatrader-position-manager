module.exports = function(grunt) {

	var dist = '/Applications/XM.app/Contents/Resources/drive_c/Program Files/XM MT4/MQL4';

	grunt.initConfig({

		copy: {
			main: {
				files:[
					{src: 'position-manager.mq4', dest: dist + '/Experts/position-manager/position-manager.mq4'},
					{src: 'scripts/long.mq4', dest: dist + '/Scripts/long.mq4'},
					{src: 'scripts/short.mq4', dest: dist + '/Scripts/short.mq4'}
				]
			}
		},

		watch: {
			scripts: {
				files: ['position-manager.mq4', 'scripts/*.mq4'],
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