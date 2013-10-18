define(['underscore', 'backbone', 'UI/component/BaseView', "UI/PlayAreaViewModel", 'text!templates/PlayArea.html'], (_, Backbone, BaseView, PlayAreaViewModel, templateText)->
  class PlayAreaView extends BaseView
    initialize: (options)->
      options ?={}
      options.template = templateText
      options.rootSelector = "#playArea"
      super(options)

    createModel:()->
      @model = new PlayAreaViewModel()



  PlayAreaView
)

