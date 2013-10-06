define(['underscore', 'backbone', 'UI/component/BaseView', "UI/administration/CreateGameViewModel","text!templates/createGame.html"], (_, Backbone, BaseView, CreateGameViewModel, templateText)->
  class CreateGameView extends BaseView
    initialize:(options)->
      options?={}
      options.template = templateText
      options.rootSelector ?= "#createGame"
      super(options)

    createModel:()->
      @model = new CreateGameViewModel(tab:@tabModel)

    events:
      'click .selected-player-marker':'selectedPlayerMarker_clicked'
      'click #confirm-create-game':'confirmCreateGame_clicked'


    setTab:(@tabModel)->

    selectedPlayerMarker_clicked:(event)->
      @model.selectUsersPlayer(event.target.id)

    confirmCreateGame_clicked:()->
      if (@model.validate())
        @model.createGame()

  CreateGameView
)

