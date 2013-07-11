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
 
require(['App',
         'backbone',
         'lib/marshallers/JSONMarshaller',
         'state/ManOWarGameState',
         'UI/RivetsExtensions'
], function(App, backbone, jsonMarshaller, state, rivetsExt) {
  // use app here

  App.initialise();
});