define(['underscore', 'backbone', "UI/administration/CreateGameViewModel","text!templates/createGame.html"], (_, Backbone, CreateGameViewModel, templateText)->
  class CreateGameView extends BaseView
    initialize:(options)->
      options?={}
      options.template = templateText
      options.rootSelector = "#createGame"
      super(options)

    createModel:()->
      @model = new CreateGameViewModel(
        invitees:new Backbone.Collection()
      )

  CreateGameView
)

