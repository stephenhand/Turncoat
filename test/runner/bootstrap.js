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
        isolateHelper:"../runner/isolateHelper",
        configureIsolate: "../runner/configureIsolate",
        spec:'../spec',
        hm: 'vendor/hm',
        esprima: 'vendor/esprima',
        jquery: 'vendor/jquery.min',
        jqModal: 'vendor/jqModal',
        underscore: 'vendor/underscore',
        backbone: 'vendor/backbone',
        rivets: 'vendor/rivets',
        uuid:'vendor/uuid',
        templates:'../templates',
        data:'../data',
        sprintf: 'vendor/sprintf'

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
        }    ,
        'sprintf':{
            exports:"sprintf"
        }
    }
});

//Isolate = require("");
require(['jquery','backbone'], function($,Backbone){
        Backbone.$=$;
    }
);
require(["isolate","configureIsolate"], function(Isolate){
    window.isolate = Isolate;
    isolate.passthru(['bootstrap','configureIsolate','underscore','backbone','jqModal','BaseView',/text!.+/,/spec\/.*/])
});


require(['spec/AppHostTest',
    'spec/AppStateTest',
    'spec/UI/RivetsExtensionsTest',
    'spec/UI/BaseViewTest',
    'spec/UI/BaseViewModelCollectionTest',
    'spec/UI/BaseViewModelItemTest',
    'spec/UI/FleetAsset2DViewModelTest',
    'spec/UI/ManOWarTableTopViewTest',
    'spec/UI/ManOWarTableTopViewModelTest',
    'spec/UI/PlayAreaViewTest',
    'spec/UI/administration/AdministrationDialogueViewTest',
    'spec/UI/administration/CreateGameViewTest',
    'spec/UI/administration/CreateGameViewModelTest',
    'spec/lib/2D/PolygonToolsTest',
    'spec/lib/2D/TransformBearingsTest',
    'spec/lib/turncoat/StateRegistryTest',
    'spec/lib/turncoat/FactoryTest',
    'spec/lib/turncoat/GameStateModelTest',
    'spec/lib/marshallers/JSONMarshallerTest',
    'spec/lib/persisters/LocalStoragePersisterTest'], function(){
    setTimeout(function () {
        console.log("Bootstrapping");
        require(['../runner/mocha']);
    })

});
