require.config({


  paths: {
    hm: "vendor/hm",
    esprima: "vendor/esprima",
    jquery: "vendor/jquery-1.10.2",
    jqModal: "vendor/jqModal",
    underscore: "vendor/underscore",
    backbone: "vendor/backbone",
    rivets: "vendor/rivets-0.6.10",
    text: "vendor/text",
    uuid:"vendor/uuid",
    sprintf: "vendor/sprintf",
		fmod: "vendor/fmod",
    moment:"vendor/moment",
    templates : "../templates",
    data : "../data",
    log4JavaScript: "vendor/log4javascript_uncompressed",
    openlayers: "vendor/openlayers",
    setTimeout : "lib/nativeShims/setTimeout",
    setInterval : "lib/nativeShims/setInterval",
    SharedWorker : "lib/nativeShims/SharedWorker",
    crypto:"http://crypto-js.googlecode.com/svn/tags/3.1.2/build/rollups/md5",
		mathjs:"http://cdnjs.cloudflare.com/ajax/libs/mathjs/0.27.0/math"
  },

  shim:{
      'jquery':{
          exports:"$"
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
      'log4JavaScript':{
          exports:"log4javascript"
      },
      'openlayers':{
          exports:"OpenLayers"
      },
      'crypto':{
          exports:"CryptoJS"
      }
  }

});
require([
    'log4JavaScript',
    'lib/turncoat/Factory',
    'lib/marshallers/JSONMarshaller',
    'lib/persisters/LocalStoragePersister',
    'lib/transports/LocalStorageTransport',
    'text!data/config.txt'
], function(log4JavaScript, Factory, jsonMarshaller, persister, transport, configText){
  config = JSON.parse(configText)
  Factory.setDefaultMarshaller(config.defaultMarshaller);
  Factory.setDefaultPersister(config.defaultPersister);
  Factory.setDefaultTransport(config.defaultTransport)
});
require(['AppHost',
         'backbone',
         'state/ManOWarGameState',
         'UI/rivets/Binders',
			   'UI/rivets/Formatters'
], function(AppHost, backbone,  state, rivetsExt) {
  // use app here

  AppHost.initialise();
});