define(['underscore',
        'backbone',
        'sprintf',
        'UI/component/BaseView',
        "UI/PlayAreaViewModel",
        "UI/board/AssetCommandOverlayView",
        "UI/board/AssetSelectionOverlayView",
        "UI/board/AssetSelectionUnderlayView",
        "UI/board/NavigationOverlayView",
        "AppState",
        'text!templates/PlayArea.html'],
(_, Backbone, sprintf, BaseView, PlayAreaViewModel, AssetCommandOverlayView, AssetSelectionOverlayView, AssetSelectionUnderlayView, NavigationOverlayView, AppState, templateText)->

  ASSETSELECTIONVIEW = "assetSelectionView"
  ASSETSELECTIONHOTSPOTS = "assetSelectionHotspots"
  ASSETCOMMANDVIEW = "assetCommandView"
  NAVIGATIONVIEW = "navigationView"

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
              overlay = new AssetSelectionUnderlayView(rootSelector:sprintf("#playArea #%s",ASSETSELECTIONVIEW))
            when ASSETSELECTIONHOTSPOTS
              overlay = new AssetSelectionOverlayView(rootSelector:sprintf("#playArea #%s",ASSETSELECTIONHOTSPOTS))
            when ASSETCOMMANDVIEW
              overlay = new AssetCommandOverlayView(rootSelector:sprintf("#playArea #%s",ASSETCOMMANDVIEW))
            when NAVIGATIONVIEW
              overlay = new NavigationOverlayView(rootSelector:sprintf("#playArea #%s",NAVIGATIONVIEW))
          if request.overlayModel? then overlay.model=request.overlayModel
          overlay.createModel();
          overlay.model.set("id",request.id)
          overlay.model.setGame(request.gameData)
          @model.get("gameBoard").get(request.layer).get(request.id)?.set("overlayModel", overlay.model)
          overlay.render()
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

