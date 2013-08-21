define(['underscore', 'backbone', 'UI/BaseView', "UI/administration/CreateGameViewModel","text!templates/createGame.html"], (_, Backbone, BaseView, CreateGameViewModel, templateText)->
  class CreateGameView extends BaseView
    initialize:(options)->
      options?={}
      options.template = templateText
      options.rootSelector = "#createGame"
      super(options)

    createModel:()->
      @model = new CreateGameViewModel()

    events:
      'click .selected-player-marker':'selectedPlayerMarker_clicked'

    selectedPlayerMarker_clicked:(event)->
      console.log("clicked")
      @model.selectUsersPlayer(event.target.id)

    render:()->
      super()
  CreateGameView
)

