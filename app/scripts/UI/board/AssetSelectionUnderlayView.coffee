define(["underscore", "backbone", "UI/component/BaseView", "UI/board/AssetSelectionOverlayViewModel", "text!templates/AssetSelectionUnderlay.html"], (_, Backbone, BaseView, AssetSelectionOverlayViewModel, templateText)->
  class AssetSelectionUnderlayView extends BaseView
    initialize: (options)->
      options ?={}
      options.template = templateText
      super(options)

    createModel:()->
      @model ?= new AssetSelectionOverlayViewModel()

  AssetSelectionUnderlayView
)