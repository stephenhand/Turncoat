define(["underscore", "backbone", "UI/component/BaseView", "UI/board/AssetSelectionOverlayViewModel", "text!templates/AssetSelectionOverlay.html"], (_, Backbone, BaseView, AssetSelectionOverlayViewModel, templateText)->
  class AssetSelectionOverlayView extends BaseView
    initialize: (options)->
      options ?={}
      options.template = templateText
      super(options)

    createModel:()->
      @model ?= new AssetSelectionOverlayViewModel()

  AssetSelectionOverlayView
)

