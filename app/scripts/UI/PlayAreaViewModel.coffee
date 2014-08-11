define(["underscore", "backbone", "UI/widgets/GameBoardViewModel", "AppState","UI/board/AssetSelectionOverlayViewModel" ], (_, Backbone, GameBoardViewModel, AppState, AssetSelectionOverlayViewModel)->

  ASSETSELECTIONVIEW = "assetSelectionView"
  ASSETSELECTIONHOTSPOTS = "assetSelectionHotspots"
  ASSETCOMMANDVIEW = "assetCommandView"
  NAVIGATIONVIEW = "navigationView"

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
          @activateOverlay=(id, layer, model)->
            @get("gameBoard").get(layer).add(id:id)
            viewAPI.requestOverlay(
              id:id
              layer:layer
              gameData:game
              overlayModel:model
            )
        else
          @activateOverlay=()->

        if (game? and AppState.get("currentUser").get("id") is game.getCurrentControllingUser().get("id"))
          @activateOverlay(ASSETSELECTIONVIEW, "underlays")
          overlayModel = @get("gameBoard").get("underlays").get(ASSETSELECTIONVIEW).get("overlayModel")
          @activateOverlay(ASSETSELECTIONHOTSPOTS, "overlays", overlayModel)
          @listenTo(overlayModel, "change:nominatedAsset", (overlay, nominated)->
            @activateOverlay(ASSETCOMMANDVIEW, "overlays")
            commandOverlayModel = @get("gameBoard").get("overlays").get(ASSETCOMMANDVIEW).get("overlayModel")
            commandOverlayModel.setAsset(nominated.get("modelId"))
            @listenTo(commandOverlayModel,"change:selectedCommand", (overlay,command)->
              if command.get("overlay")?
                @activateOverlay(command.get("overlay"), "overlays")
                actionOverlayModel = @get("gameBoard").get("overlays").get(command.get("overlay")).get("overlayModel")
                actionOverlayModel.setAsset(command.get("target").get("modelId"))
                actionOverlayModel.setAction(command)
            )
          )

    activateOverlay:()->
  )

  PlayAreaViewModel
)

