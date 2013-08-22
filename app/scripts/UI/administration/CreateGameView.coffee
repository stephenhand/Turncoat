define(['underscore', 'backbone', 'UI/BaseView', "UI/administration/CreateGameViewModel","text!templates/createGame.html"], (_, Backbone, BaseView, CreateGameViewModel, templateText)->
  class CreateGameView extends BaseView
    initialize:(options)->
      options?={}
      options.template = templateText
      options.rootSelector ?= "#createGame"
      super(options)

    createModel:()->
      @model = new CreateGameViewModel()

    events:
      'click .selected-player-marker':'selectedPlayerMarker_clicked'
      'click #confirm-create-game':'confirmCreateGame_clicked'


    selectedPlayerMarker_clicked:(event)->
      @model.selectUsersPlayer(event.target.id)

    confirmCreateGame_clicked:()->
      if (@model.validate())
        @model.createGame()

  CreateGameView
)

