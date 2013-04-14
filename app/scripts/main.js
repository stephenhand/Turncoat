require.config({


  paths: {
    hm: 'vendor/hm',
    esprima: 'vendor/esprima',
    jquery: 'vendor/jquery.min',
    underscore: 'vendor/underscore',
    backbone: 'vendor/backbone',
    rivets: 'vendor/rivets',
    text: 'vendor/text',
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
      }
  }

});
 
require(['app','backbone','lib/marshallers/JSONMarshaller'], function(app, backbone, jsonMarshaller) {
  // use app here
  app.start();
});