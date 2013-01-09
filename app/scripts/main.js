require.config({


  paths: {
    hm: 'vendor/hm',
    esprima: 'vendor/esprima',
    jquery: 'vendor/jquery.min',
    underscore: 'vendor/underscore',
    backbone: 'vendor/backbone',
    rivets: 'vendor/rivets',
    text: 'vendor/text',
    templates : '../templates'
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
 
require(['app','backbone'], function(app, backbone) {
  // use app here
  app.start();
});