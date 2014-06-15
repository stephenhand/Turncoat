define(['underscore', 'backbone', 'UI/component/BaseView', "UI/PlayAreaViewModel", "UI/board/AssetSelectionOverlayView", "UI/board/AssetSelectionUnderlayView", "AppState", 'text!templates/PlayArea.html'], (_, Backbone, BaseView, PlayAreaViewModel, AssetSelectionOverlayView, AssetSelectionUnderlayView, AppState, templateText)->

  ASSETSELECTIONVIEW = "assetSelectionView"
  ASSETSELECTIONHOTSPOTS = "assetSelectionHotspots"

  class PlayAreaView extends BaseView
    initialize: (options)->
      options ?={}
      options.template = templateText
      options.rootSelector = "#playArea"
      super(options)

    createModel:()->
      @model = new PlayAreaViewModel()
      @model.setViewAPI(
        requestOverlay:(request)=>
          if not request.gameData? then throw new Error("game data missing.")
          overlay = null
          switch request.id
            when ASSETSELECTIONVIEW
              overlay = new AssetSelectionUnderlayView()
            when ASSETSELECTIONHOTSPOTS
              overlay = new AssetSelectionOverlayView()
          overlay.createModel();
          overlay.model.set("id",request.id)
          overlay.model.setGame(request.gameData)
          @model.get("gameBoard").get(request.layer).set([overlay.model], remove:false)
      )

    routeChanged:(route)->
      if ((route.parts?.length ? 0)>1)
        @model.setGame(AppState.loadGame(route.parts[1]))
      else
        @model.setGame()

    render:()->
      super()



  PlayAreaView
)

