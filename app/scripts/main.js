require.config({


  paths: {
    hm: 'vendor/hm',
    esprima: 'vendor/esprima',
    jquery: 'vendor/jquery.min',
    jqModal: 'vendor/jqModal',
    underscore: 'vendor/underscore',
    backbone: 'vendor/backbone',
    rivets: 'vendor/rivets',
    text: 'vendor/text',
    uuid:'vendor/uuid',
    sprintf: 'vendor/sprintf',
    templates : '../templates',
    data : '../data'
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
      },
      'sprintf':{
          exports:"sprintf"
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