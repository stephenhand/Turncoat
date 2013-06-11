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
        rivets: 'vendor/rivets',
        uuid:'vendor/uuid',
        templates:'../templates',
        data:'../data'
    },
    shim:{
        'jquery':{
            exports:'$'
        },
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
    isolate.passthru(['bootstrap','configureIsolate','underscore','backbone','BaseView',/text!.+/,/spec\/.*/])
});


require(['spec/AppTest',
    'spec/UI/RivetsExtensionsTest',
    'spec/UI/BaseViewTest',
    'spec/UI/BaseViewModelCollectionTest',
    'spec/UI/BaseViewModelItemTest',
    'spec/UI/FleetAsset2DViewModelTest',
    'spec/UI/ManOWarTableTopViewTest',
    'spec/UI/PlayAreaViewTest',
    'spec/lib/2D/PolygonToolsTest',
    'spec/lib/2D/TransformBearingsTest',
    'spec/lib/turncoat/StateRegistryTest',
    'spec/lib/turncoat/FactoryTest',
    'spec/lib/turncoat/GameStateModelTest',
    'spec/lib/marshallers/JSONMarshallerTest'], function(){
    setTimeout(function () {
        console.log("Bootstrapping");
        require(['../runner/mocha']);
    })

});
