define(['underscore', 'backbone', 'UI/widgets/GameBoardViewModel', ], (_, Backbone, GameBoardViewModel)->
  PlayAreaViewModel = Backbone.Model.extend(
    initialize: (m, options)->
      @set("gameBoard", new GameBoardViewModel())
      if options?
        if options.assetSelectionView
          options.assetSelectionView.createModel()
          options.assetSelectionView.model.set("id","playAreaAssetSelection")
          @get("gameBoard").get("overlays").add(options.assetSelectionView.model)
          options.assetSelectionView.rootSelector = "#playAreaAssetSelection"

    setGame:(game)->
      @get("gameBoard").setGame(game)


  )

  PlayAreaViewModel
)

