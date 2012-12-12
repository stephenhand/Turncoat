require.config({


  paths: {
    hm: 'vendor/hm',
    esprima: 'vendor/esprima',
    jquery: 'vendor/jquery.min',
    underscore: 'vendor/underscore',
    backbone: 'vendor/backbone'
  }
});
 
require(['app','backbone'], function(app, backbone) {
  // use app here
  app.start();
});