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
        jsHamcrest: '../lib/jshamcrest',
        jsMockito: '../lib/jsmockito',
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
        rivets: 'vendor/rivets-0.5.13',
        uuid:'vendor/uuid',
        moment:'vendor/moment',
        templates:'../templates',
        data:'../data',
        log4JavaScript: 'vendor/log4JavaScript_uncompressed',
        sprintf: 'vendor/sprintf',
        setTimeout: 'lib/nativeShims/setTimeout',
        setInterval : 'lib/nativeShims/setInterval'
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
        },
        'sprintf':{
            exports:"sprintf"
        },
        'setTimeout':{
            exports:"setTimeout"
        },
        'jsHamcrest':{
            exports:'JsHamcrest'
        },
        'jsMockito':{
            exports:'JsMockito'
        },
        'log4JavaScript':{
            exports:"log4javascript"
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
    isolate.passthru(['bootstrap','configureIsolate','underscore','backbone','jqModal','vendor/log4javascript_uncompressed','component/BaseView',/text!.+/,/spec\/.*/])
});


require(['vendor/log4javascript_uncompressed','spec/AppHostTest',
    'spec/AppStateTest',
    'spec/UI/RivetsExtensionsTest',
    'spec/UI/rivets/binders/FeedItemTest',
    'spec/UI/rivets/AdapterTest',
    'spec/UI/routing/RouteTest',
    'spec/UI/routing/RouterTest',
    'spec/UI/component/BaseViewTest',
    'spec/UI/component/ObservingViewModelCollectionTest',
    'spec/UI/component/ObservingViewModelItemTest',
    'spec/UI/component/ObservableOrderCollectionTest',
    'spec/UI/FleetAsset2DViewModelTest',
    'spec/UI/ManOWarTableTopViewTest',
    'spec/UI/ManOWarTableTopViewModelTest',
    'spec/UI/PlayAreaViewTest',
    'spec/UI/PlayAreaViewModelTest',
    'spec/UI/administration/AdministrationDialogueViewTest',
    'spec/UI/administration/AdministrationDialogueViewModelTest',
    'spec/UI/administration/CreateGameViewTest',
    'spec/UI/administration/CreateGameViewModelTest',
    'spec/UI/administration/ReviewChallengesViewTest',
    'spec/UI/administration/ReviewChallengesViewModelTest',
    'spec/lib/backboneTools/ModelProcessorTest',
    'spec/lib/2D/PolygonToolsTest',
    'spec/lib/2D/TransformBearingsTest',
    'spec/lib/turncoat/StateRegistryTest',
    'spec/lib/turncoat/FactoryTest',
    'spec/lib/turncoat/GameStateModelTest',
    'spec/lib/turncoat/LogEntryTest',
    'spec/lib/turncoat/GameHeaderTest',
    'spec/lib/turncoat/GameTest',
    'spec/lib/turncoat/UserTest',
    'spec/lib/logging/LoggerFactoryTest',
    'spec/lib/marshallers/JSONMarshallerTest',
    'spec/lib/persisters/LocalStoragePersisterTest',
    'spec/lib/transports/LocalStorageTransportTest'], function(){
    setTimeout(function () {
        console.log("Bootstrapping");
        require(['../runner/mocha']);
    })

});
