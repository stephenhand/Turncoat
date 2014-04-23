define(['underscore', 'backbone', 'UI/component/BaseView', "UI/PlayAreaViewModel", "UI/board/AssetSelectionOverlayView", "UI/board/AssetSelectionUnderlayView", "AppState", 'text!templates/PlayArea.html'], (_, Backbone, BaseView, PlayAreaViewModel, AssetSelectionOverlayView, AssetSelectionUnderlayView, AppState, templateText)->
  class PlayAreaView extends BaseView
    initialize: (options)->
      options ?={}
      options.template = templateText
      options.rootSelector = "#playArea"
      super(options)


    createModel:()->
      @assetSelectionView = new AssetSelectionUnderlayView()
      @assetSelectionHotspots =   new AssetSelectionOverlayView()
      @model = new PlayAreaViewModel(null,
        assetSelectionView:@assetSelectionView
        assetSelectionHotspots:@assetSelectionHotspots
      )

    routeChanged:(route)->
      if ((route.parts?.length ? 0)>1) then @model.setGame(AppState.loadGame(route.parts[1])) else @model.setGame()

    render:()->
      super()


  PlayAreaView
)

