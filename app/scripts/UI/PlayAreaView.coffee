define(['underscore', 'backbone', 'UI/component/BaseView', "UI/PlayAreaViewModel","AppState", 'text!templates/PlayArea.html'], (_, Backbone, BaseView, PlayAreaViewModel, AppState, templateText)->
  class PlayAreaView extends BaseView
    initialize: (options)->
      options ?={}
      options.template = templateText
      options.rootSelector = "#playArea"
      super(options)

    createModel:()->
      @model = new PlayAreaViewModel()

    routeChanged:(route)->
      if ((route.parts?.length ? 0)>1) then @model.setGame(AppState.loadGame(route.parts[1])) else @model.setGame()


  PlayAreaView
)

