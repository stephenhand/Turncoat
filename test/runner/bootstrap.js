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
        isolate: "../runner/isolate",
        configureIsolate: "../runner/configureIsolate",
        testUtils: '../runner/testUtils',
        spec:'../spec',
        hm: 'vendor/hm',
        esprima: 'vendor/esprima',
        jquery: 'vendor/jquery.min',
        underscore: 'vendor/underscore',
        backbone: 'vendor/backbone',
        rivets: 'vendor/rivets'

    },
    shim:{
        'underscore':{
            exports:"_"
        },
        'backbone':{
            deps:['underscore'],
            exports:"Backbone"
        },
        'rivets':{
            exports:"rivets"
        }
    }
});

//Isolate = require("");

require(["isolate","configureIsolate"], function(Isolate){
    window.isolate = Isolate;
    isolate.passthru(['bootstrap','configureIsolate','underscore','backbone','jquery','BaseView','App',/spec\/.*/])
});


require(['spec/AppTest', 'spec/UI/BaseViewTest', 'spec/lib/2D/PolygonToolsTest', 'spec/lib/2D/TransformBearingsTest'], function(){
    setTimeout(function () {
        console.log("Bootstrapping");
        require(['../runner/mocha']);
    })

});
