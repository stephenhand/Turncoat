/**
 * Created by stephen.hand on 05/05/2014.
 */
//https://gist.github.com/marcusellis05/8050184
var grunt = require('grunt')
	, tasks = grunt.cli.options.tasks;

if (tasks.length === 0){
	tasks = ['debug'];
}

grunt.cli.options.tasks = null;
grunt.cli.tasks = tasks;
grunt.cli();