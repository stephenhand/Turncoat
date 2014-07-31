define([
    "underscore",
    "jquery",
    "backbone",
    "lib/2D/SVGTools",
    "UI/component/BaseView",
    "UI/board/NavigationOverlayViewModel",
    "text!templates/NavigationOverlay.html"],
(_, $, Backbone, SVGTools, BaseView, NavigationOverlayViewModel, templateText)->
  class NavigationOverlayView extends BaseView
    initialize: (options)->
      options ?={}
      options.template = templateText
      super(options)

    createModel:()->
      @model ?= new NavigationOverlayViewModel()

    navigationMouseMove:(ev)->
      coords= SVGTools.pixelCoordsToSVGUnits(ev.target, ev.offsetX, ev.offsetY)
      @model.updatePreview(coords.x, coords.y)

    events:
      "mousemove #navigationHotspot":"navigationMouseMove"


  NavigationOverlayView
)

