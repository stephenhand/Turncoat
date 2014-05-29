// Generated on <%= (new Date).toISOString().split('T')[0] %> using
// <%= pkg.name %> <%= pkg.version %>
'use strict';

// # Globbing
// for performance reasons we're only matching one level down:
// 'test/spec/{,*/}*.js'
// If you want to recursively match all subfolders, use:
// 'test/spec/**/*.js'
Error.stackTraceLimit = 200;
module.exports = function (grunt) {
	grunt.loadNpmTasks('grunt-contrib-coffee');
	grunt.loadNpmTasks('grunt-contrib-watch');
	grunt.loadNpmTasks('grunt-contrib-copy');
	grunt.loadNpmTasks('grunt-contrib-clean');
	grunt.loadNpmTasks('grunt-contrib-connect');

	// Configurable paths
	var config = {
		app: 'app',
		test: 'test',
		debug:'debug/',
		release: 'release'
	};

	// Define the configuration for all the tasks
	grunt.initConfig({
		coffee:{
			debug:{
				files:[{
					expand:true,
					dest:config.debug,
					src:"app/scripts/**/*.coffee",
					rename: function(dest, src) {
						return dest + src.replace(/\.coffee$/, ".js");
					},
					cwd:"."
				}]
			},
			test:{
				files:[{
					expand:true,
					dest:config.debug,
					src:["test/{spec,runner}/**/*.coffee","app/scripts/**/*.coffee"],
					rename: function(dest, src) {
						return dest + src.replace(/\.coffee$/, ".js").replace(/^app\//,"test/");
					},
					cwd:"."
				}]
			}
		},
		copy:{
			debug:{
				files:[{
					expand:true,
					dest:config.debug,
					src:"app/**/*",
					filter:function(p){
						return !(/\.coffee$/.test(p));
					}
				}]
			},
			test:{
				files:[{
					expand:true,
					dest:config.debug,
					src:["test/**/*","app/{scripts,templates,data}/**/*"],
					rename: function(dest, src) {
						return dest + src.replace(/^app\//,"test/");
					},
					filter:function(p){
						return !(/\.coffee$/.test(p));
					}
				}]
			}
		},
		clean:{
			debug:[config.debug+"app"],
			test:[config.debug+"test"]
		},
		connect: {
			options: {
				open: true,
				// Change this to '0.0.0.0' to access the server from outside
				hostname: 'localhost',
			},
			debug:{
				options: {
					port: 9000,
					base: config.debug + 'app'
				}
			},
			test: {
				options: {
					port: 9001,
					base: config.debug+'test'
				}
			},
			release: {
				options: {
					base: 'release',
					livereload: false
				}
			}
		},
		watch:{
			debug:{
				tasks:["compile:debug"],
				files:"app/**/*",
				options:{
					//livereload: 35729
				}
			},
			test:{
				tasks:["compile:test"],
				files:{src:["app/**/*","test/**/*"]},
				options:{
					//livereload: 35729
				}
			}
		}
	});;



	grunt.registerTask('compile', function (target) {
		grunt.task.run([
			'clean:debug',
			'coffee:debug',
			'copy:debug'
		]);
		if (target==="test"){
			grunt.task.run([
				'clean:test',
				'coffee:test',
				'copy:test'
			]);
		}
  });

	grunt.registerTask('debug', function () {
		grunt.task.run([
			'compile:debug',
			'connect:debug',
			'watch:debug'
		]);
	});

	grunt.registerTask('browser-test', function () {
		grunt.task.run([
			'compile:test',
			'connect:test',
			'watch:test'

		]);
	});
	grunt.registerTask('test', function () {
		grunt.task.run([
			'browser-test'
		]);
	});

};






