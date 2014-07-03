define([
    "underscore",
    "jquery",
    "backbone",
    "UI/component/BaseView",
    "UI/board/AssetCommandOverlayViewModel",
    "text!templates/AssetCommandOverlay.html"],
(_, $, Backbone, BaseView, AssetCommandOverlayViewModel, templateText)->
  class AssetCommandOverlayView extends BaseView
    initialize: (options)->
      options ?={}
      options.template = templateText
      super(options)
    createModel:()->
      if (!@model?)
        @model = new AssetCommandOverlayViewModel()
        @listenTo(@model.get("nominatedAssets"),"add", (asset)->
          window.setTimeout(()->
            if (asset?) then $("."+asset.get("UUID")+"-animate-show").each(()->
              @beginElement()
            )

          )
        )


  AssetCommandOverlayView
)

