define(['underscore', 'backbone', 'UI/BaseView', 'text!templates/PlayArea.html'], (_, Backbone, BaseView, templateText)->
  class PlayAreaView extends BaseView
    initialize: (options)->
      options.template = templeText
      options.rootSelector = "#playArea"
      super(options)

  PlayAreaView
)

