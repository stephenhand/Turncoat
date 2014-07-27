define([
    "underscore",
    "jquery",
    "backbone",
    "UI/component/BaseView",
    "UI/board/NavigationOverlayViewModel",
    "text!templates/NavigationOverlay.html"],
(_, $, Backbone, BaseView, NavigationOverlayViewModel, templateText)->
  class NavigationOverlayView extends BaseView
    initialize: (options)->
      options ?={}
      options.template = templateText
      super(options)

    createModel:()->
      @model ?= new NavigationOverlayViewModel()

  NavigationOverlayView
)

