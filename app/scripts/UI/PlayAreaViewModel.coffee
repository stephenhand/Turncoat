define(["underscore", "backbone", "UI/widgets/GameBoardViewModel", "AppState" ], (_, Backbone, GameBoardViewModel, AppState)->

  ASSETSELECTIONVIEW = "assetSelectionView"
  ASSETSELECTIONHOTSPOTS = "assetSelectionHotspots"

  PlayAreaViewModel = Backbone.Model.extend(
    initialize: (m, options)->
      @set("gameBoard", new GameBoardViewModel())
      viewAPI =
        requestOverlay:()->
      @setViewAPI=(api)->
        if typeof api.requestOverlay isnt "function" then throw new Error("Invalid view API, must support 'requestOverlay' method")
        viewAPI = api

      @setGame=(game)->
        @get("gameBoard").setGame(game)

        if (game?)
          @activateOverlay=(id, layer)->
            @get("gameBoard").get(layer).add(new Backbone.Model(id:id))
            viewAPI.requestOverlay(
              id:id
              layer:layer
              gameData:game
            )
        else
          @activateOverlay=()->

        if (game? and AppState.get("currentUser").get("id") is game.getCurrentControllingUser().get("id"))
          @activateOverlay(ASSETSELECTIONVIEW, "underlays")
          @activateOverlay(ASSETSELECTIONHOTSPOTS, "overlays")

    activateOverlay:()->
  )

  PlayAreaViewModel
)

