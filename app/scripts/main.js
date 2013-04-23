require.config({


  paths: {
    hm: 'vendor/hm',
    esprima: 'vendor/esprima',
    jquery: 'vendor/jquery.min',
    underscore: 'vendor/underscore',
    backbone: 'vendor/backbone',
    rivets: 'vendor/rivets',
    text: 'vendor/text',
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
          exports:"Rivets"
      },
      'sprintf':{
          exports:"sprintf"
      }
  }

});
 
require(['app',
         'backbone',
         'lib/marshallers/JSONMarshaller',
        'state/ManOWarGameState',
        'UI/RivetsExtensions'
], function(app, backbone, jsonMarshaller, player, fleetAsset) {
  // use app here
  app.start();
});