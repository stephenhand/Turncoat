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
        expect: "../lib/expect",
        chai: "../lib/chai",
        jsHamcrest: "../lib/jshamcrest",
				matchers: "../lib/matchers",
				operators: "../lib/operators",
				assertThat: "../lib/assertThat",
        jsMockito: "../lib/jsmockito",
				verifiers: "../lib/verifiers",
				install: "../lib/install",
        isolate: "../runner/isolate",
        isolateHelper:"../runner/isolateHelper",
        configureIsolate: "../runner/configureIsolate",
        spec:"../spec",
        hm: "vendor/hm",
        esprima: "vendor/esprima",
        jquery: "vendor/jquery.min",

        jqModal: "vendor/jqModal",
        underscore: "vendor/underscore",
        backbone: "vendor/backbone-1.1.2",
        rivets: "vendor/rivets-0.5.13",
        uuid:"vendor/uuid",
        moment:"vendor/moment",
        templates:"../templates",
        data:"../data",
        log4JavaScript: "vendor/log4JavaScript_uncompressed",
        sprintf: "vendor/sprintf",
				fmod: 'vendor/fmod',
        setTimeout: "lib/nativeShims/setTimeout",
        setInterval : "lib/nativeShims/setInterval",
        crypto:[
					"http://crypto-js.googlecode.com/svn/tags/3.1.2/build/rollups/md5",
					"lib/cryptoStub",
				],
				mathjs:"http://cdnjs.cloudflare.com/ajax/libs/mathjs/0.27.0/math"
    },
    shim:{
        "jquery":{
            exports:"$"
        },
        "underscore":{
            exports:"_"
        },
        "backbone":{
            deps:["underscore"],
            exports:"Backbone"
        },
        "rivets":{
            exports:"rivets"
        },
        "sprintf":{
            exports:"sprintf"
        },
        "setTimeout":{
            exports:"setTimeout"
        },
        "jsHamcrest":{
            exports:"JsHamcrest"
        },
        "jsMockito":{
            exports:"JsMockito"
        },
        "log4JavaScript":{
            exports:"log4javascript"
        },
        "crypto":{
            exports:"CryptoJS"
        }
    }
});

//Isolate = require("");
require(["jquery","backbone"], function($,Backbone){
        Backbone.$=$;
    }
);
require(["isolate","configureIsolate"], function(Isolate){
    window.isolate = Isolate;
    isolate.passthru(["bootstrap","configureIsolate","underscore","backbone","jqModal","vendor/log4javascript_uncompressed","component/BaseView",/text!.+/,/spec\/.*/])
});


require(["vendor/log4javascript_uncompressed","spec/AppHostTest",
    "spec/AppStateTest",
    "spec/UI/rivets/BindersTest",
		"spec/UI/rivets/FormattersTest",
    "spec/UI/rivets/binders/FeedItemTest",
    "spec/UI/rivets/AdapterTest",
    "spec/UI/routing/RouteTest",
    "spec/UI/routing/RouterTest",
    "spec/UI/component/BaseViewTest",
    "spec/UI/component/ObservingViewModelCollectionTest",
    "spec/UI/component/ObservingViewModelItemTest",
    "spec/UI/component/ObservableOrderCollectionTest",
    "spec/UI/widgets/GameListViewModelTest",
    "spec/UI/widgets/PlayerListViewModelTest",
    "spec/UI/widgets/GameBoardViewModelTest",
    "spec/UI/FleetAsset2DViewModelTest",
    "spec/UI/ManOWarTableTopViewTest",
    "spec/UI/ManOWarTableTopViewModelTest",
    "spec/UI/PlayAreaViewTest",
    "spec/UI/PlayAreaViewModelTest",
    "spec/UI/administration/AdministrationDialogueViewTest",
    "spec/UI/administration/AdministrationDialogueViewModelTest",
    "spec/UI/administration/CreateGameViewTest",
    "spec/UI/administration/CreateGameViewModelTest",
    "spec/UI/administration/CurrentGamesViewModelTest",
    "spec/UI/administration/CurrentGamesViewTest",
    "spec/UI/administration/ReviewChallengesViewTest",
    "spec/UI/administration/ReviewChallengesViewModelTest",
    "spec/UI/board/GameBoardOverlayViewTest",
		"spec/UI/board/AssetCommandOverlayViewTest",
		"spec/UI/board/AssetCommandOverlayViewModelTest",
    "spec/UI/board/AssetSelectionUnderlayViewTest",
    "spec/UI/board/AssetSelectionOverlayViewTest",
		"spec/UI/board/AssetSelectionOverlayViewModelTest",
		"spec/UI/board/FleetAssetSelectionViewModelTest",
		"spec/UI/board/NavigationOverlayViewTest",
		"spec/UI/board/NavigationOverlayViewModelTest",
		"spec/UI/board/NominatedAssetOverlayViewModelTest",
		"spec/rules/v0_0_1/ships/AssetPermittedActionsTest",
		"spec/rules/v0_0_1/ships/actions/MoveTest",
		"spec/rules/v0_0_1/ships/events/ChangePositionTest",
    "spec/rules/ManOWarMoveTest",
    "spec/state/FleetAssetTest",
		"spec/state/PlayerTest",
    "spec/state/ManOWarGameStateTest",
    "spec/lib/backboneTools/ModelProcessorTest",
    "spec/lib/2D/PolygonToolsTest",
		"spec/lib/2D/SVGToolsTest",
    "spec/lib/2D/TransformBearingsTest",
    "spec/lib/turncoat/TypeRegistryTest",
    "spec/lib/turncoat/FactoryTest",
    "spec/lib/turncoat/GameStateModelTest",
    "spec/lib/turncoat/LogEntryTest",
    "spec/lib/turncoat/GameHeaderTest",
    "spec/lib/turncoat/GameTest",
    "spec/lib/turncoat/MoveTest",
		"spec/lib/turncoat/RuleBookEntryTest",
    "spec/lib/turncoat/UserTest",
    "spec/lib/logging/LoggerFactoryTest",
    "spec/lib/marshallers/JSONMarshallerTest",
    "spec/lib/persisters/LocalStoragePersisterTest",
    "spec/lib/transports/LocalStorageTransportTest"], function(){
    setTimeout(function () {
        console.log("Bootstrapping");
        require(["../runner/mocha"]);
    })

});
