define(['underscore', 'backbone', 'UI/widgets/GameBoardViewModel', ], (_, Backbone, GameBoardViewModel)->
  PlayAreaViewModel = Backbone.Model.extend(
    initialize: (m, options)->
      @set("gameBoard", new GameBoardViewModel())


    setGame:(game)->
#      if @options?
#        if @options.assetSelectionView
#          @options.assetSelectionView.createModel()
#          @options.assetSelectionView.model.set("id","playAreaAssetSelection")
#          @get("gameBoard").get("underlays").add(@options.assetSelectionView.model)
#          @options.assetSelectionView.rootSelector = "#playAreaAssetSelection"
#          @options.assetSelectionView.render()
#          if @options.assetSelectionHotspots
#            @options.assetSelectionHotspots.createModel()
#            @options.assetSelectionHotspots.model.set("id","playAreaAssetHotspots")
#            @get("gameBoard").get("overlays").add(@options.assetSelectionHotspots.model)
#            @options.assetSelectionHotspots.rootSelector = "#playAreaAssetHotspots"
#            @options.assetSelectionHotspots.render()

      @get("gameBoard").setGame(game)

      if (game?)
        @activateOverlay=(id)->
          @get("gameBoard").get("overlays").add(new Backbone.Model(id:id))
          @trigger("overlaySpawned",
            id:id
            gameData:game
          )


      else
        @activateOverlay=(id)->

    activateOverlay:()->





  )

  PlayAreaViewModel
)

