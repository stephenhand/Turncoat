define(["underscore", "backbone", "UI/component/BaseView", "UI/administration/CurrentGamesViewModel","text!templates/CurrentGames.html"], (_, Backbone, BaseView, CurrentGamesViewModel, templateText)->
  class CurrentGamesView extends BaseView
    initialize:(options)->
      options?={}
      options.template = templateText
      options.rootSelector ?= "#currentGames"
      super(options)

    setTab:(@tabModel)->

    createModel:()->
      @model = new CurrentGamesViewModel(tab:@tabModel)

    events:
      'click .left-panel .list-item':'gameListItem_clicked'

    gameListItem_clicked:(event)->
      @model.selectGame(event.currentTarget.id)

  CurrentGamesView

)


