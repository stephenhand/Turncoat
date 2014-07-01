define([
    "underscore",
    "jquery",
    "backbone",
    "UI/component/BaseView",
    "UI/board/AssetSelectionOverlayViewModel",
    "text!templates/AssetSelectionOverlay.html"],
(_, $, Backbone, BaseView, AssetCommandOverlayViewModel, templateText)->
  class AssetCommandOverlayView extends BaseView
    createModel:()->
      @model ?= new AssetCommandOverlayViewModel()


  AssetCommandOverlayView
)

