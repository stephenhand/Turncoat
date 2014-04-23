define(["underscore", "backbone", "UI/component/BaseView"], (_, Backbone , BaseView)->
  class GameBoardOverlayView extends BaseView

    activate:(game)->
      @model.setGame(game)

    deactivate:()->

  GameBoardOverlayView
)

