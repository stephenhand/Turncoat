require.config({


  paths: {
    hm: 'vendor/hm',
    esprima: 'vendor/esprima',
    jquery: 'vendor/jquery-1.10.2',
    jqModal: 'vendor/jqModal',
    underscore: 'vendor/underscore',
    backbone: 'vendor/backbone',
    rivets: 'vendor/rivets-0.5.13',
    text: 'vendor/text',
    uuid:'vendor/uuid',
    sprintf: 'vendor/sprintf',
    moment:'vendor/moment',
    templates : '../templates',
    data : '../data',
    setTimeout : 'lib/nativeShims/setTimeout',
    setInterval : 'lib/nativeShims/setInterval'
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
      }
  }

});
require(['lib/turncoat/Factory',
         'lib/marshallers/JSONMarshaller',
         'lib/persisters/LocalStoragePersister',
         'text!data/config.txt'
], function(Factory, jsonMarshaller, persister, configText){
  config = JSON.parse(configText)
  Factory.setDefaultMarshaller(config.defaultMarshaller);
  Factory.setDefaultPersister(config.defaultPersister);
});
require(['AppHost',
         'backbone',
         'state/ManOWarGameState',
         'UI/RivetsExtensions'
], function(AppHost, backbone,  state, rivetsExt) {
  // use app here

  AppHost.initialise();
});