/**
 * Created with JetBrains WebStorm.
 * User: stephenhand
 * Date: 02/12/12
 * Time: 16:54
 * To change this template use File | Settings | File Templates.
 */
require.config({
    baseUrl:"scripts",

    paths: {
        expect: '../lib/expect',
        chai: '../lib/chai',
        spec:'../spec',
        hm: 'vendor/hm',
        esprima: 'vendor/esprima',
        jquery: 'vendor/jquery.min',
        underscore: 'vendor/underscore',
        backbone: 'vendor/backbone'
    }
});

require(['spec/AppTest'], function(){

    setTimeout(function () {
        console.log("Bootstrapping");
        require(['../runner/mocha']);
    })

})
