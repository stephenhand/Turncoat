define(["underscore", "jquery", "backbone", "UI/component/BaseView", "UI/board/AssetSelectionOverlayViewModel", "text!templates/AssetSelectionOverlay.html"], (_, $, Backbone, BaseView, AssetSelectionOverlayViewModel, templateText)->
  class AssetSelectionOverlayView extends BaseView
    initialize: (options)->
      options ?={}
      options.template = templateText
      super(options)

    createModel:()->
      @model ?= new AssetSelectionOverlayViewModel()
      @listenTo(@model,"change:nominatedAsset", (model, asset)->
        if (asset?) then $("."+asset.get("UUID")+"-animate-show").each(()->
          @beginElement()
        )
      )

    events:
      "click .asset-selection-highlight":"hotspotClicked"

    hotspotClicked:(event)->
      @model.setNominatedAsset(@model.get("ships").find(
          (m)->
            m.get("UUID")?.toString()? and event.currentTarget.getAttribute("asset-id") is m.get("UUID").toString()
      ))




  AssetSelectionOverlayView
)

